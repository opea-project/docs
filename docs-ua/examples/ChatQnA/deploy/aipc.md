# Розгортання на одному вузлі з Ollama на AIPC

У цьому розділі розгортання описано одновузлове попереднє розгортання ChatQnA
на прикладі комп'ютерів OPEA для розгортання за допомогою Ollama. Існує декілька
slice-n-dice способів увімкнути RAG з моделями vectordb та LLM, але тут ми
розглянемо один варіант для зручності: ми покажемо, як
побудувати e2e chatQnA з Redis VectorDB та моделлю llama-3,
розгорнуту на клієнтському процесорі. Для отримання додаткової інформації про те, як налаштувати екземпляр IDC для продовження роботи,
будь ласка, дотримуйтесь інструкцій тут ***getting started section***. Якщо у вас
не маєте екземпляра IDC, ви можете пропустити цей крок і переконатися, що всі
***system level validation*** метрики, такі як версії докерів.

## Огляд

Існує декілька способів створити варіант використання ChatQnA. У цьому підручнику ми розглянемо, як увімкнути наведений нижче список мікросервісів від OPEA
GenAIComps для розгортання одновузлового мегасервісного рішення Ollama.

1. Підготовка даних
2. Вбудовування
3. Ретривер
4. Переранжування
5. LLM з Ollama

Tня має на меті показати, як використовувати Redis vectordb для моделі RAG і 
моделі llama-3 на клієнтських комп'ютерах Intel. Ми розглянемо 
як налаштувати докер-контейнер для запуску мікросервісів та мегасервісів. 
Потім рішення буде використовувати зразок набору даних Nike у форматі PDF. Користувачі 
можуть задати питання про Nike і отримати відповідь у вигляді чату за замовчуванням для 
до 1024 токенів. Рішення розгортається за допомогою інтерфейсу користувача. Ви можете використовувати 2 режими:
1. Базовий інтерфейс
2. Діалоговий інтерфейс

Діалоговий інтерфейс не є обов'язковим, але підтримується в цьому прикладі, якщо ви зацікавлені в його використанні.

## Передумови 

Першим кроком є клонування GenAIExamples та GenAIComps. GenAIComps - це 
основні необхідні компоненти, що використовуються для створення прикладів, які ви знайдете в GenAIExamples і розгортання їх як мікросервісів.

```
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
```

Перевірте тег релізу
```
cd GenAIComps
git checkout tags/v1.0
```

У прикладах використовуються модельні ваги від Ollama і langchain.

Встановіть Ваш [HuggingFace](https://huggingface.co/) обліковий запис і генеруйте
[user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Налаштування токена HuggingFace
```
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

У прикладі потрібно встановити `host_ip` для розгортання мікросервісів на
кінцевому пристрої з увімкненими портами. Встановлення змінної host_ip env
```
export host_ip=$(hostname -I | awk '{print $1}')
```

Переконайтеся, що ви налаштували проксі-сервери, якщо ви перебуваєте за брандмауером
```
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Підготовка (створення / витягування) докер-образів

Цей крок передбачає створення/витягування (можливо, у майбутньому) відповідних докер-образів з покроковим описом процесу і перевіркою працездатності в кінці. Для
ChatQnA знадобляться такі образи докерів: embedding, retriever,
rerank, LLM і dataprep. Крім того, вам потрібно буде зібрати докер-образи для
мегасервісу ChatQnA та інтерфейсу користувача ( діалоговий React UI не є обов'язковим). Загалом є 8 обов'язкових і один необов'язковий докер-образ.

Докер-образи, необхідні для встановлення прикладу, потрібно збирати локально, проте незабаром Intel викладе ці образи на докер-хаб.

### Створення/витягування образів мікросервісів

З папки `GenAIComps`.

#### Побудова образу підготовки даних

```
docker build --no-cache -t opea/dataprep-redis:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/dataprep/redis/langchain/Dockerfile .
```

#### Побудова образу для вбудовування

```
docker build --no-cache -t opea/embedding-tei:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/embeddings/tei/langchain/Dockerfile .
```

#### Побудова образу ретривера

```
 docker build --no-cache -t opea/retriever-redis:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/retrievers/redis/langchain/Dockerfile .
```

#### Побудова образу переранжування

```
docker build --no-cache -t opea/reranking-tei:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/reranks/tei/Dockerfile .
```

#### Побудова образу LLM

Налаштовуємо сервіс Ollama LLM однією командою
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Далі ми створимо докер мікросервісу Ollama. Це встановить точку входу
необхідну для того, щоб Ollama відповідала прикладам ChatQnA
```
docker build --no-cache -t opea/llm-ollama:latest --build-arg https_proxy=$https_proxy \
   --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/ollama/langchain/Dockerfile .
```

Налаштування конфігурації сервісу Ollama

Файл конфігурації сервісу Ollama знаходиться в `/etc/systemd/system/ollama.service`.
Відредагуйте файл, щоб встановити середовище OLLAMA_HOST (замініть **${host_ip}** на IPV4 вашого хоста).
```
Environment="OLLAMA_HOST=${host_ip}:11434"
```
Встановіть оточення https_proxy для Ollama, якщо ваша система отримує доступ до мережі через проксі.
```
Environment="https_proxy=http://proxy.example.com:8080"
```
Перезапустіть сервіси Ollama
```
sudo systemctl daemon-reload
sudo systemctl restart ollama.service
```

Pull LLM model

```bash
export OLLAMA_HOST=http://${host_ip}:11434
ollama pull llama3
ollama list

NAME            ID              SIZE    MODIFIED
llama3:latest   365c0bd3c000    4.7 GB  5 days ago
```

### Побудова образів Мегасервісу

Мегасервіс - це трубопровід, який передає дані через різні мікросервіси, кожен з яких виконує різні завдання. Ми визначаємо різні
мікросервіси і потік даних між ними у файлі `chatqna.py`, скажімо, у
цьому прикладі вихід мікросервісу вбудовування буде входом мікросервісу пошуку
який, у свою чергу, передасть дані мікросервісу ранжування і так далі.
Ви також можете додавати нові або видаляти деякі мікросервіси і налаштовувати
мегасервіс відповідно до ваших потреб.

Створіть образ мегасервісу для цього варіанту використання

```
cd ..
cd GenAIExamples/ChatQnA
git checkout tags/v1.0
```

```
docker build --no-cache -t opea/chatqna:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f Dockerfile .
```

### Створення образів інших сервісів

#### Створення образу інтерфейсу користувача

Як вже було сказано, ви можете створити 2 режими інтерфейсу

*Базовий інтерфейс*

```
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-ui:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile .
```

*Діалоговий інтерфейс*
Якщо вам потрібен розмовний досвід, скористайтеся мегасервісом chatqna.

```
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-conversation-ui:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile.react .
```

### Перевірка здорового глузду.
Перед тим, як перейти до наступного кроку, перевірте, чи у вас є наведений нижче набір докер-образів:

* opea/dataprep-redis:latest
* opea/embedding-tei:latest
* opea/retriever-redis:latest
* opea/reranking-tei:latest
* opea/llm-ollama:latest
* opea/chatqna:latest
* opea/chatqna-ui:latest

## Встановлення кейсу використання

Як вже згадувалося, у цьому прикладі використання буде використано наступну комбінацію GenAIComps з інструментами

| Компоненти кейсу використання | Інструменти |   Модель     | Тип Сервісу |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   Ollama     | llama3                   |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Інструменти та моделі, згадані у таблиці, налаштовуються або через змінну оточення чи файл `compose.yaml`.

Встановіть необхідні змінні оточення для встановлення варіанту використання

> Примітка: Замініть `host_ip` на вашу зовнішню IP-адресу. Не використовуйте localhost
> для наведеного нижче набору змінних оточення

### Dataprep

    export DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6007/v1/dataprep"
    export DATAPREP_GET_FILE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/get_file"
    export DATAPREP_DELETE_FILE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/delete_file"

### VectorDB

    export REDIS_URL="redis://${host_ip}:6379"
    export INDEX_NAME="rag-redis"

### Embedding Service

    export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
    export EMBEDDING_SERVICE_HOST_IP=${host_ip}
    export RETRIEVER_SERVICE_HOST_IP=${host_ip}
    export TEI_EMBEDDING_ENDPOINT="http://${host_ip}:6006"

### Reranking Service

    export RERANK_MODEL_ID="BAAI/bge-reranker-base"
    export TEI_RERANKING_ENDPOINT="http://${host_ip}:8808"
    export RERANK_SERVICE_HOST_IP=${host_ip}

### LLM Service

    export LLM_SERVICE_HOST_IP=${host_ip}
    export OLLAMA_ENDPOINT=http://${host_ip}:11434
    export OLLAMA_MODEL="llama3"

### Megaservice

    export MEGA_SERVICE_HOST_IP=${host_ip}
    export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8888/v1/chatqna"

## Розгортання кейсу використання
У цьому посібнику ми будемо розгортати за допомогою docker compose з наданого
YAML-файлу.  Інструкції docker compose повинні запустити всі вищезгадані сервіси як контейнери.

```
cd GenAIExamples/ChatQnA/docker_compose/intel/cpu/aipc
docker compose -f compose.yaml up -d
```

### Валідація мікросервісу 

#### Перевірка змінних оточення
Перевірте журнал запуску за допомогою `docker compose -f ./compose.yaml logs`.
Попереджувальні повідомлення виводять змінні, якщо їх **НЕ** встановлено.

    ubuntu@aipc:~/GenAIExamples/ChatQnA/docker_compose/intel/cpu/aipc$ docker compose -f ./compose.yaml up -d
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] /home/ubuntu/GenAIExamples/ChatQnA/docker_compose/intel/cpu/aipc/compose.yaml: `version` is obsolete

#### Перевірте стан контейнера

Перевірте, чи всі контейнери, запущені за допомогою docker compose, запущено

Наприклад, у прикладі ChatQnA запускається 11 докерів (сервісів), перевірте ці докери контейнери запущено, тобто всі контейнери `STATUS` мають значення `Up`.
Для швидкої перевірки працездатності спробуйте `docker ps -a`, щоб побачити, чи всі контейнери запущено

```
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED          STATUS                      PORTS                                                                                  NAMES
5db065a9fdf9   opea/chatqna-ui:latest                                  "docker-entrypoint.s…"   29 seconds ago   Up 25 seconds               0.0.0.0:5173->5173/tcp, :::5173->5173/tcp                                              chatqna-aipc-ui-server
6fa87927d00c   opea/chatqna:latest                                     "python chatqna.py"      29 seconds ago   Up 25 seconds               0.0.0.0:8888->8888/tcp, :::8888->8888/tcp                                              chatqna-aipc-backend-server
bdc93be9ce0c   opea/retriever-redis:latest                             "python retriever_re…"   29 seconds ago   Up 3 seconds                0.0.0.0:7000->7000/tcp, :::7000->7000/tcp                                              retriever-redis-server
add761b504bc   opea/reranking-tei:latest                               "python reranking_te…"   29 seconds ago   Up 26 seconds               0.0.0.0:8000->8000/tcp, :::8000->8000/tcp                                              reranking-tei-aipc-server
d6b540a423ac   opea/dataprep-redis:latest                              "python prepare_doc_…"   29 seconds ago   Up 26 seconds               0.0.0.0:6007->6007/tcp, :::6007->6007/tcp                                              dataprep-redis-server
6662d857a154   opea/embedding-tei:latest                               "python embedding_te…"   29 seconds ago   Up 26 seconds               0.0.0.0:6000->6000/tcp, :::6000->6000/tcp                                              embedding-tei-server
8b226edcd9db   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "text-embeddings-rou…"   29 seconds ago   Up 27 seconds               0.0.0.0:8808->80/tcp, :::8808->80/tcp                                                  tei-reranking-server
e1fc81b1d542   redis/redis-stack:7.2.0-v9                              "/entrypoint.sh"         29 seconds ago   Up 27 seconds               0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp   redis-vector-db
051e0d68e263   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "text-embeddings-rou…"   29 seconds ago   Up 27 seconds               0.0.0.0:6006->80/tcp, :::6006->80/tcp                                                  tei-embedding-server
632a6634b06b   opea/llm-ollama                                         "bash entrypoint.sh"     29 seconds ago   Up 27 seconds               0.0.0.0:9000->9000/tcp, :::9000->9000/tcp                                              llm-ollama
```

## Взаємодія з розгортанням ChatQnA

У цьому розділі ви дізнаєтеся про різні способи взаємодії з
розгорнутими мікросервісами

### Dataprep Microservice (необов'язково)

Якщо ви хочете додати або оновити базу знань за замовчуванням, ви можете скористатися такими командами. Мікросервіс dataprep витягує тексти з різних джерел даних, розбиває дані на частини, вбудовує кожну частину за допомогою мікросервісу embedding і зберігає вбудовані вектори у базі даних векторів redis.

Завантаження локального файлу `nke-10k-2023.pdf` :

```
curl -X POST "http://${host_ip}:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F "files=@./nke-10k-2023.pdf"
```

Ця команда оновлює базу знань, завантажуючи локальний файл для обробки.
Змініть шлях до файлу відповідно до вашого середовища.

Додайте базу знань через HTTP-посилання:

```
curl -X POST "http://${host_ip}:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F 'link_list=["https://opea.dev"]'
```

Ця команда оновлює базу знань, надсилаючи список HTTP-посилань для обробки.

Крім того, ви можете отримати список файлів, які ви завантажили:

```
curl -X POST "http://${host_ip}:6007/v1/dataprep/get_file" \
     -H "Content-Type: application/json"

```

Щоб видалити завантажений вами файл/посилання, ви можете скористатися наступними командами:

#### Видалити посилання
```
# The dataprep service will add a .txt postfix for link file

curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "https://opea.dev.txt"}' \
     -H "Content-Type: application/json"
```

#### Видалити файл

```
curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "nke-10k-2023.pdf"}' \
     -H "Content-Type: application/json"
```

#### Видалення всіх завантажених файлів і посилань

```
curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "all"}' \
     -H "Content-Type: application/json"
```
### TEI Embedding Service

Сервіс вбудовування TEI приймає на вхід рядок, вбудовує його у вектор певної довжини, визначеної моделлю вбудовування, і повертає цей вкладений вектор.

```
curl ${host_ip}:6006/embed \
    -X POST \
    -d '{"inputs":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json'
```

У цьому прикладі використовується модель вбудовування «BAAI/bge-base-en-v1.5», яка має розмір вектора 768. Отже, результатом виконання команди curl буде вбудований вектор довжиною 768.

### Embedding Microservice
Мікросервіс вбудовування залежить від сервісу вбудовування TEI. З точки зору
вхідних параметрів, він приймає рядок, вбудовує його у вектор за допомогою сервісу вбудовування TEI, додає інші параметри за замовчуванням, необхідні для мікросервісу пошуку і повертає його.

```
curl http://${host_ip}:6000/v1/embeddings\
  -X POST \
  -d '{"text":"hello"}' \
  -H 'Content-Type: application/json'
```
### Retriever Microservice

Щоб споживати мікросервіс retriever, потрібно згенерувати mock embedding
вектор за допомогою скрипту на Python. Довжина вектора вбудовування визначається
моделлю вбудовування. Тут ми використовуємо модель EMBEDDING_MODEL_ID=«BAAI/bge-base-en-v1.5», розмір вектора якої становить 768.

Перевірте векторну розмірність вашої моделі вбудовування і встановіть
розмірність `your_embedding`, що відповідає їй.

```
export your_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")

curl http://${host_ip}:7000/v1/retrieval \
  -X POST \
  -d "{\"text\":\"test\",\"embedding\":${your_embedding}}" \
  -H 'Content-Type: application/json'

```
Вихід мікросервісу ретрівера складається з унікального ідентифікатора для
запиту, початкового запиту або вхідного запиту до мікросервісу пошуку, списку top
`n` знайдених документів, що відповідають вхідному запиту, та top_n, де n позначає
кількість документів, які потрібно повернути.
На виході виводиться текст, що відповідає вхідним даним:
```
{"id":"27210945c7c6c054fa7355bdd4cde818","retrieved_docs":[{"id":"0c1dd04b31ab87a5468d65f98e33a9f6","text":"Company: Nike. financial instruments are subject to master netting arrangements that allow for the offset of assets and liabilities in the event of default or early termination of the contract.\nAny amounts of cash collateral received related to these instruments associated with the Company's credit-related contingent features are recorded in Cash and\nequivalents and Accrued liabilities, the latter of which would further offset against the Company's derivative asset balance. Any amounts of cash collateral posted related\nto these instruments associated with the Company's credit-related contingent features are recorded in Prepaid expenses and other current assets, which would further\noffset against the Company's derivative liability balance. Cash collateral received or posted related to the Company's credit-related contingent features is presented in the\nCash provided by operations component of the Consolidated Statements of Cash Flows. The Company does not recognize amounts of non-cash collateral received, such\nas securities, on the Consolidated Balance Sheets. For further information related to credit risk, refer to Note 12 — Risk Management and Derivatives.\n2023 FORM 10-K 68Table of Contents\nThe following tables present information about the Company's derivative assets and liabilities measured at fair value on a recurring basis and indicate the level in the fair\nvalue hierarchy in which the Company classifies the fair value measurement:\nMAY 31, 2023\nDERIVATIVE ASSETS\nDERIVATIVE LIABILITIES"},{"id":"1d742199fb1a86aa8c3f7bcd580d94af","text": ... }

```

### TEI Reranking Service

TСервіс переранжування TEI переранжує документи, повернуті пошуковою службою
сервісом. Він споживає запит і список документів і повертає індекс документа в порядку зменшення показника схожості. Документ, що відповідає повернутому індексу з найбільшою оцінкою, є найбільш релевантним для вхідного запиту.
```
curl http://${host_ip}:8808/rerank \
    -X POST \
    -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
    -H 'Content-Type: application/json'
```

Вивід:  `[{"index":1,"score":0.9988041},{"index":0,"score":0.022948774}]`


### Reranking Microservice

Мікросервіс переранжування використовує сервіс переранжування TEI і підставляє
відповідь параметрами за замовчуванням, необхідними для мікросервісу LLM.

```
curl http://${host_ip}:8000/v1/reranking\
  -X POST \
  -d '{"initial_query":"What is Deep Learning?", "retrieved_docs": \
     [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Вхідними даними для мікросервісу є `initial_query`  і список знайдених
документів, і він виводить найбільш релевантний документ до початкового запиту разом з іншими параметрами за замовчуванням, такими як температура, `repetition_penalty`, `chat_template` і так далі. Ми також можемо отримати перші n документів, задавши `top_n` як один із вхідних параметрів. Наприклад:

```
curl http://${host_ip}:8000/v1/reranking\
  -X POST \
  -d '{"initial_query":"What is Deep Learning?" ,"top_n":2, "retrieved_docs": \
     [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Це вивід:

```
{"id":"e1eb0e44f56059fc01aa0334b1dac313","query":"Human: Answer the question based only on the following context:\n    Deep learning is...\n    Question: What is Deep Learning?","max_new_tokens":1024,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}

```
Ви можете помітити, що мікросервіси ранжування мають стан ('ID' та інші метадані),
в той час як сервіс переранжування не має.

### Ollama Service

```
curl http://${host_ip}:11434/api/generate -d '{"model": "llama3", "prompt":"What is Deep Learning?"}'
```

Сервіс Ollama генерує текст для підказки введення. Ось очікуваний результат
від Ollama:

```
{"model":"llama3","created_at":"2024-09-05T08:47:17.160752424Z","response":"Deep","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:18.229472564Z","response":" learning","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:19.594268648Z","response":" is","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:21.129254135Z","response":" a","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:22.066555829Z","response":" sub","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:22.993695854Z","response":"field","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:24.315183296Z","response":" of","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:25.337741889Z","response":" machine","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:26.232468605Z","response":" learning","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:27.584534136Z","response":" that","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:28.50201424Z","response":" involves","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:29.895471763Z","response":" the","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:31.204128984Z","response":" use","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:32.231884525Z","response":" of","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:33.510913894Z","response":" artificial","done":false}
{"model":"llama3","created_at":"2024-09-05T08:47:34.516291108Z","response":" neural","done":false}
...
```

### LLM Microservice
```
curl http://${host_ip}:9000/v1/chat/completions\
  -X POST \
  -d '{"query":"What is Deep Learning?","max_new_tokens":17,"top_k":10,"top_p":0.95,\
     "typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}' \
  -H 'Content-Type: application/json'

```

Ви отримаєте згенерований нижче текст від LLM:

```
data: b'\n'
data: b'\n'
data: b'Deep'
data: b' learning'
data: b' is'
data: b' a'
data: b' subset'
data: b' of'
data: b' machine'
data: b' learning'
data: b' that'
data: b' uses'
data: b' algorithms'
data: b' to'
data: b' learn'
data: b' from'
data: b' data'
data: [DONE]
```

### MegaService

```
curl http://${host_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model":  "'"${OLLAMA_MODEL}"'",
     "messages": "What is the revenue of Nike in 2023?"
     }'

```

Ось результат для вашого посилання:

```
data: b'\n'
data: b'An'
data: b'swer'
data: b':'
data: b' In'
data: b' fiscal'
data: b' '
data: b'2'
data: b'0'
data: b'2'
data: b'3'
data: b','
data: b' N'
data: b'I'
data: b'KE'
data: b','
data: b' Inc'
data: b'.'
data: b' achieved'
data: b' record'
data: b' Rev'
data: b'en'
data: b'ues'
data: b' of'
data: b' $'
data: b'5'
data: b'1'
data: b'.'
data: b'2'
data: b' billion'
data: b'.'
data: b'</s>'
data: [DONE]
```

## Перевірка журналу контейнерів докера

Перевірте журнал контейнера:

`docker logs <CONTAINER ID> -t`


Перевірте журнал за `docker logs f7a08f9867f9 -t`.

Також ви можете перевірити загальний журнал за допомогою наступної команди, де
compose.yaml - це файл конфігурації мегасервісу docker-compose.

```
docker compose -f ./docker_compose/intel/cpu/apic/compose.yaml logs
```

## Запуск інтерфейсу користувача

### Базовий інтерфейс користувача

Щоб отримати доступ до інтерфейсу, відкрийте в браузері наступну URL-адресу: http://{host_ip}:5173. За замовчуванням інтерфейс працює на внутрішньому порту 5173. Якщо ви бажаєте використовувати інший порт хоста для доступу до інтерфейсу, ви можете змінити мапінг портів у файлі compose.yaml, як показано нижче:
```
  chaqna-aipc-ui-server:
    image: opea/chatqna-ui:latest
    ...
    ports:
      - "80:5173"
```

### Діалоговий інтерфейс

Щоб отримати доступ до інтерфейсу діалогового інтерфейсу (заснованого на реакції), змініть сервіс інтерфейсу у файлі compose.yaml. Замініть сервіс chaqna-aipc-ui-server на сервіс chatqna-aipc-conversation-ui-server, як показано у конфігурації нижче:
```
chaqna-aipc-conversation-ui-server:
  image: opea/chatqna-conversation-ui:latest
  container_name: chatqna-aipc-conversation-ui-server
  environment:
    - APP_BACKEND_SERVICE_ENDPOINT=${BACKEND_SERVICE_ENDPOINT}
    - APP_DATA_PREP_SERVICE_URL=${DATAPREP_SERVICE_ENDPOINT}
  ports:
    - "5174:80"
  depends_on:
    - chaqna-aipc-backend-server
  ipc: host
  restart: always
```

Після запуску сервісів відкрийте у браузері наступну URL-адресу: http://{host_ip}:5174. За замовчуванням інтерфейс працює на внутрішньому порту 80. Якщо ви бажаєте використовувати інший порт хоста для доступу до інтерфейсу, ви можете змінити мапінг портів у файлі compose.yaml, як показано нижче:

```
  chaqna-aipc-conversation-ui-server:
    image: opea/chatqna-conversation-ui:latest
    ...
    ports:
      - "80:80"
```

### Зупинка роботи сервісів

Після того, як ви закінчите роботу з усім трубопроводом і захочете зупинитися і видалити всі контейнери, скористайтеся командою, наведеною нижче:

```
docker compose -f compose.yaml down
```
