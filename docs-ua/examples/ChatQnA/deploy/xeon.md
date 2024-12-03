# Розгортання на одному вузлі за допомогою vLLM або TGI на процесорах Xeon Scalable

У цьому розділі розгортання описано одновузлове попереднє розгортання ChatQnA
на прикладі комп'ютерів OPEA для розгортання за допомогою служби vLLM або TGI. Існує декілька
slice-n-dice способів увімкнути RAG з моделями vectordb та LLM, але тут ми
розглянемо один варіант для зручності: ми покажемо, як
побудувати e2e chatQnA з Redis VectorDB та моделлю neural-chat-7b-v3-3,
розгорнутої на IDC. Для отримання додаткової інформації про те, як налаштувати екземпляр IDC для продовження,
будь ласка, дотримуйтесь інструкцій тут (***getting started section***). Якщо у вас
не маєте екземпляра IDC, ви можете пропустити цей крок і переконатися, що всі
(***system level validation***) метрики, такі як версії докерів.

## Огляд

Існує декілька способів створити варіант використання ChatQnA. У цьому підручнику ми розглянемо, як увімкнути наведений нижче список мікросервісів з OPEA
GenAIComps для розгортання одновузлового рішення vLLM або мегасервісу TGI.

1. Підготовка даних
2. Вбудовування
3. Ретривер
4. Переранжування
5. LLM з vLLM або TGI

Рішення має на меті показати, як використовувати Redis vectordb для RAG та
neural-chat-7b-v3-3 моделі на процесорах Intel Xeon Scalable. Ми розглянемо
як налаштувати докер-контейнер для запуску мікросервісів та мегасервісів. Рішення
буде використовувати зразок набору даних Nike у форматі PDF. Користувачі
можуть задати питання про Nike і отримати відповідь у вигляді чату за замовчуванням для до 1024 токенів. Рішення розгортається за допомогою інтерфейсу користувача. Існує 2 режими, які ви можете використовувати:

1. Базовий інтерфейс
2. Діалоговий інтерфейс

Діалоговий інтерфейс не є обов'язковим, але підтримується у цьому прикладі, якщо ви зацікавлені у його використанні.

## Передумови

Першим кроком є клонування GenAIExamples та GenAIComps. GenAIComps - це
основні необхідні компоненти, що використовуються для створення прикладів, які ви знайдете в GenAIExamples, і розгортання їх як мікросервісів.

```
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
```

Checkout the release tag
```
cd GenAIComps
git checkout tags/v1.0
```

У прикладах використовуються ваги моделей з HuggingFace та langchain.

Налаштуйте свій обліковий запис [HuggingFace](https://huggingface.co/) і згенеруйте
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

Цей крок передбачає створення/витягування (можливо, у майбутньому) відповідних докер-образів з покроковим описом процесу і перевіркою працездатності в кінці. 
Для ChatQnA знадобляться такі докер-образи: embedding, retriever, rerank, LLM і dataprep. Крім того, вам потрібно буде зібрати докер-образи для
мегасервісу ChatQnA та інтерфейсу користувача (діалоговий React UI не є обов'язковим). Загалом є 8 обов'язкових і один необов'язковий докер-образ.
 
Докер-образи, необхідні для встановлення прикладу, потрібно збирати локально, проте
незабаром Intel викладе ці образи на докер-хаб.

### Створення/витягування образів мікросервісу

З папки `GenAIComps`.

#### Створення образу Dataprep

```
docker build --no-cache -t opea/dataprep-redis:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/dataprep/redis/langchain/Dockerfile .
```

#### Створення образу вбудовування

```
docker build --no-cache -t opea/embedding-tei:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/embeddings/tei/langchain/Dockerfile .
```

#### Створення образу ретривера

```
 docker build --no-cache -t opea/retriever-redis:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/retrievers/redis/langchain/Dockerfile .
```

#### Створення образу переранжування

```
docker build --no-cache -t opea/reranking-tei:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/reranks/tei/Dockerfile .
```

#### Створення образу LLM

We build the vllm docker image from source
```
git clone https://github.com/vllm-project/vllm.git
cd ./vllm/
docker build --no-cache -t opea/vllm:latest --build-arg https_proxy=$https_proxy \
   --build-arg http_proxy=$http_proxy -f Dockerfile.cpu .
cd ..
```

Далі ми створимо докер мікросервісу vllm. Це встановить точку входу необхідну для того, щоб vllm відповідав прикладам ChatQnA
```
docker build --no-cache -t opea/llm-vllm:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy \
  -f comps/llms/text-generation/vllm/langchain/Dockerfile.microservice .

```

```
docker build --no-cache -t opea/llm-tgi:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/tgi/Dockerfile .
```

### Створення образів Mega Service

Мегасервіс - це трубопровід, який передає дані через різні мікросервіси, кожен з яких виконує різні завдання. Ми визначаємо різні
мікросервіси і потік даних між ними у файлі `chatqna.py`, скажімо, у цьому прикладі вихід мікросервісу вбудовування буде входом мікросервісу пошуку, який, у свою чергу, передасть дані мікросервісу ранжування і так далі. Ви також можете додавати нові або видаляти деякі мікросервіси і налаштовувати
мегасервіс відповідно до ваших потреб.
 
Створення образу мегасервісу для цього кейсу використання

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
Якщо ви хочете отримати розмовний досвід з мегасервісом chatqna.

```
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-conversation-ui:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile.react .
```

### Перевірка здорового глузду.
Перед тим, як перейти до наступного кроку, перевірте наявність наведеного нижче набору образів докерів:

* opea/dataprep-redis:latest
* opea/embedding-tei:latest
* opea/retriever-redis:latest
* opea/reranking-tei:latest
* opea/vllm:latest
* opea/chatqna:latest
* opea/chatqna-ui:latest
* opea/llm-vllm:latest

* opea/dataprep-redis:latest
* opea/embedding-tei:latest
* opea/retriever-redis:latest
* opea/reranking-tei:latest
* opea/chatqna:latest
* opea/chatqna-ui:latest
* opea/llm-tgi:latest

## Налаштування кейсу використання

Як вже згадувалося, у цьому прикладі використання буде використано наступну комбінацію GenAIComps з інструментами

|компоненти кейсів використання | Інструменти |   Модель     | Тип сервісу |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   vLLM       |Intel/neural-chat-7b-v3-3 |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Інструменти та моделі, згадані у таблиці, налаштовуються або за допомогою змінної оточення або через файл `compose_vllm.yaml`.

|компоненти кейсів використання | Інструменти |   Модель     | Тип сервісу |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   TGI        |Intel/neural-chat-7b-v3-3 |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Інструменти та моделі, згадані у таблиці, налаштовуються або через змінну оточення або файл `compose.yaml`.

Встановіть необхідні змінні оточення для налаштування варіанту використання

> Примітка: Rзамініть `host_ip` на вашу зовнішню IP-адресу. Не використовуйте localhost
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

    export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
    export LLM_SERVICE_HOST_IP=${host_ip}
    export LLM_SERVICE_PORT=9000
    export vLLM_LLM_ENDPOINT="http://${host_ip}:9009"

    export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
    export LLM_SERVICE_HOST_IP=${host_ip}
    export LLM_SERVICE_PORT=9000
    export TGI_LLM_ENDPOINT="http://${host_ip}:9009"

### Megaservice

    export MEGA_SERVICE_HOST_IP=${host_ip}
    export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8888/v1/chatqna"

## Розгортання кейсу використання

У цьому посібнику ми будемо розгортати за допомогою docker compose з наданого
YAML-файлу. Інструкції docker compose повинні запустити всі вищезгадані сервіси як контейнери.

```
cd GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon
docker compose -f compose_vllm.yaml up -d
```

```
cd GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon
docker compose -f compose.yaml up -d
```

### Валідація мікросервісу
#### Перевірка змінних Env

Перевірте журнал запуску за допомогою `docker compose -f ./compose_vllm.yaml logs`.
Попереджувальні повідомлення виводять змінні, якщо їх **НЕ** встановлено.

    ubuntu@xeon-vm:~/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon$ docker compose -f ./compose_vllm.yaml up -d
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] /home/ubuntu/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon/compose_vllm.yaml: `version` is obsolete

Перевірте журнал запуску за допомогою `docker compose -f ./compose.yaml logs`.
Попереджувальні повідомлення виводять змінні, якщо їх **НЕ** встановлено.

    ubuntu@xeon-vm:~/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon$ docker compose -f ./compose.yaml up -d
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] /home/ubuntu/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon/compose.yaml: `version` is obsolete

#### Перевірка статусу контейнера

Перевірте, чи всі контейнери, запущені за допомогою docker compose, запущено

Наприклад, у прикладі ChatQnA запускається 11 докерів (сервісів), перевірте ці докер-контейнери запущено, тобто всі контейнери `STATUS` мають значення `Up`.
Для швидкої перевірки працездатності спробуйте `docker ps -a`, щоб побачити, чи всі контейнери запущено

| CONTAINER ID | IMAGE | COMMAND | CREATED | STATUS | PORTS | Names |
| ------------ | ----- | ------- | ------- | ------ | ----- | ----- |
| 3b5fa9a722da | opea/chatqna-ui:latest | "docker-entrypoint.s…" | 32 hours ago | Up 2 hours | 0.0.0.0:5173->5173/tcp, :::5173->5173/tcp | chatqna-xeon-ui-server |
| d3b37f3d1faa | opea/chatqna:latest | "python chatqna.py" | 32 hours ago | Up 2 hours | 0.0.0.0:8888->8888/tcp, :::8888->8888/tcp | chatqna-xeon-backend-server
| b3e1388fa2ca |  opea/reranking-tei:latest | "python reranking_te…" | 32 hours ago | Up 2 hours | 0.0.0.0:8000->8000/tcp, :::8000->8000/tcp | reranking-tei-xeon-server|
| 24a240f8ad1c  | opea/retriever-redis:latest | "python retriever_re…" | 32 hours ago | Up 2 hours  | 0.0.0.0:7000->7000/tcp, :::7000->7000/tcp |  retriever-redis-server |
| 9c0d2a2553e8 | opea/embedding-tei:latest | "python embedding_te…" | 32 hours ago | Up 2 hours | 0.0.0.0:6000->6000/tcp, :::6000->6000/tcp | embedding-tei-server |
| 24cae0db1a70 | opea/llm-vllm:latest | "bash entrypoint.sh" | 32 hours ago | Up 2 hours | 0.0.0.0:9000->9000/tcp, :::9000->9000/tcp | llm-vllm-server |
| ea3986c3cf82 | opea/dataprep-redis:latest | "python prepare_doc_…" | 32 hours ago | Up 2 hours | 0.0.0.0:6007->6007/tcp, :::6007->6007/tcp |  dataprep-redis-server |
| e10dd14497a8 | redis/redis-stack:7.2.0-v9 | "/entrypoint.sh" | 32 hours ago |  Up 2 hours | 0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp | redis-vector-db |
| b98fa07a4f5c | opea/vllm:latest | "python3 -m vllm.ent…" | 32 hours ago | Up 2 hours | 0.0.0.0:9009->80/tcp, :::9009->80/tcp | vllm-service |
| 79276cf45a47 | ghcr.io/huggingface/text-embeddings-inference:cpu-1.2 |  "text-embeddings-rou…" | 32 hours ago | Up 2 hours | 0.0.0.0:6006->80/tcp, :::6006->80/tcp | tei-embedding-server |
| 4943e5f6cd80 | ghcr.io/huggingface/text-embeddings-inference:cpu-1.2 |  "text-embeddings-rou…" | 32 hours ago | Up 2 hours | 0.0.0.0:8808->80/tcp, :::8808->80/tcp | tei-reranking-server |


| CONTAINER ID | IMAGE | COMMAND | CREATED | STATUS | PORTS | NAMES |
| ------------ | ----- | ------- | ------- | ------ | ----- | ----- |
| 3b5fa9a722da | opea/chatqna-ui:latest |                                 "docker-entrypoint.s…"  | 32 hours ago  | Up 2 hours | 0.0.0.0:5173->5173/tcp, :::5173->5173/tcp | chatqna-xeon-ui-server |
| d3b37f3d1faa | opea/chatqna:latest | "python chatqna.py" | 32 hours ago | Up 2 hours | 0.0.0.0:8888->8888/tcp, :::8888->8888/tcp | chatqna-xeon-backend-server |
| b3e1388fa2ca | opea/reranking-tei:latest | "python reranking_te…" | 32 hours ago | Up 2 hours | 0.0.0.0:8000->8000/tcp, :::8000->8000/tcp | reranking-tei-xeon-server |
| 24a240f8ad1c | opea/retriever-redis:latest | "python retriever_re…" | 32 hours ago | Up 2 hours | 0.0.0.0:7000->7000/tcp, :::7000->7000/tcp | retriever-redis-server |
| 9c0d2a2553e8  | opea/embedding-tei:latest | "python embedding_te…" | 32 hours ago | Up 2 hours | 0.0.0.0:6000->6000/tcp, :::6000->6000/tcp |  embedding-tei-server |
| 24cae0db1a70 | opea/llm-tgi:latest | "bash entrypoint.sh" | 32 hours ago | Up 2 hours | 0.0.0.0:9000->9000/tcp, :::9000->9000/tcp | llm-tgi-server |
| ea3986c3cf82 |  opea/dataprep-redis:latest  | "python prepare_doc_…" | 32 hours ago | Up 2 hours | 0.0.0.0:6007->6007/tcp, :::6007->6007/tcp | dataprep-redis-server |
| e10dd14497a8 | redis/redis-stack:7.2.0-v9 | "/entrypoint.sh" | 32 hours ago | Up 2 hours | 0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp | redis-vector-db |
| 79276cf45a47 | ghcr.io/huggingface/text-embeddings-inference:cpu-1.2 |  "text-embeddings-rou…" | 32 hours ago | Up 2 hours | 0.0.0.0:6006->80/tcp, :::6006->80/tcp | tei-embedding-server |
| 4943e5f6cd80 | ghcr.io/huggingface/text-embeddings-inference:cpu-1.2 | "text-embeddings-rou…" | 32 hours ago | Up 2 hours | 0.0.0.0:8808->80/tcp, :::8808->80/tcp | tei-reranking-server |

## Взаємодія з розгортанням ChatQnA

У цьому розділі ви дізнаєтеся про різні способи взаємодії з
розгорнутими мікросервісами

### Мікросервіс Dataprep (необов'язково)

Якщо ви хочете додати або оновити базу знань за замовчуванням, ви можете скористатися такими командами. Мікросервіс dataprep витягує тексти з різних джерел даних, розбиває дані на частини, вбудовує кожну частину за допомогою мікросервісу embedding і зберігає вбудовані вектори у базі даних векторів redis.

Завантаження локального файлу `nke-10k-2023.pdf`:

```
curl -X POST "http://${host_ip}:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F "files=@./nke-10k-2023.pdf"
```

Ця команда оновлює базу знань, завантажуючи локальний файл для обробки.
Змініть шлях до файлу відповідно до вашого середовища.

Додайте базу знань за допомогою HTTP-посилань:

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

#### Видалення посилання
```
# Служба dataprep додасть постфікс .txt до файлу посилання

curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "https://opea.dev.txt"}' \
     -H "Content-Type: application/json"
```

#### Видалення файлу
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
### Сервіс вбудовування TEI

Сервіс вбудовування TEI приймає на вхід рядок, вбудовує його у вектор певної довжини, визначеної моделлю вбудовування, і повертає цей вкладений вектор.

```
curl ${host_ip}:6006/embed \
    -X POST \
    -d '{"inputs":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json'
```

У цьому прикладі використовується модель вбудовування «BAAI/bge-base-en-v1.5», яка має розмір вектора 768. Отже, результатом виконання команди curl буде вбудований вектор довжиною 768.

### Мікросервіс Вбудовування 
Мікросервіс вбудовування залежить від сервісу вбудовування TEI. З точки зору
вхідних параметрів, він приймає рядок, вбудовує його у вектор за допомогою TEI
вбудовування, додає інші параметри за замовчуванням, необхідні для мікросервісу
мікросервісу пошуку і повертає його.

```
curl http://${host_ip}:6000/v1/embeddings\
  -X POST \
  -d '{"text":"hello"}' \
  -H 'Content-Type: application/json'
```
### Мікросервіс ретриверів

Щоб споживати мікросервіс retriever, потрібно згенерувати mock embedding
вектор за допомогою Python-скрипту. Довжина вектора вбудовування визначається
моделлю вбудовування. Тут ми використовуємо модель EMBEDDING_MODEL_ID=«BAAI/bge-base-en-v1.5», розмір вектора якої дорівнює 768.

Перевірте векторну розмірність вашої моделі вбудовування і встановіть
розмірність `your_embedding` рівною їй.

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
кількість документів, що мають бути повернуті.

На виході отримується текст, який відповідає вхідним даним:
```
{"id":"27210945c7c6c054fa7355bdd4cde818","retrieved_docs":[{"id":"0c1dd04b31ab87a5468d65f98e33a9f6","text":"Company: Nike. financial instruments are subject to master netting arrangements that allow for the offset of assets and liabilities in the event of default or early termination of the contract.\nAny amounts of cash collateral received related to these instruments associated with the Company's credit-related contingent features are recorded in Cash and\nequivalents and Accrued liabilities, the latter of which would further offset against the Company's derivative asset balance. Any amounts of cash collateral posted related\nto these instruments associated with the Company's credit-related contingent features are recorded in Prepaid expenses and other current assets, which would further\noffset against the Company's derivative liability balance. Cash collateral received or posted related to the Company's credit-related contingent features is presented in the\nCash provided by operations component of the Consolidated Statements of Cash Flows. The Company does not recognize amounts of non-cash collateral received, such\nas securities, on the Consolidated Balance Sheets. For further information related to credit risk, refer to Note 12 — Risk Management and Derivatives.\n2023 FORM 10-K 68Table of Contents\nThe following tables present information about the Company's derivative assets and liabilities measured at fair value on a recurring basis and indicate the level in the fair\nvalue hierarchy in which the Company classifies the fair value measurement:\nMAY 31, 2023\nDERIVATIVE ASSETS\nDERIVATIVE LIABILITIES"},{"id":"1d742199fb1a86aa8c3f7bcd580d94af","text": ... }

```

### Сервіс переранжування TEI

Сервіс переранжування TEI переранжує документи, повернуті пошуковим сервісом. Вона споживає запит і список документів і повертає індекс документа на основі убування показника схожості. Документ, що відповідає повернутому індексу з найбільшою оцінкою, є найбільш релевантним для вхідного запиту.
```
curl http://${host_ip}:8808/rerank \
    -X POST \
    -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
    -H 'Content-Type: application/json'
```

Вивід це:  `[{"index":1,"score":0.9988041},{"index":0,"score":0.022948774}]`


### Мікросервіс Переранжування

Мікросервіс переранжування використовує сервіс переранжування TEI і підставляє відповідь з параметрами за замовчуванням, необхідними для мікросервісу llm.

```
curl http://${host_ip}:8000/v1/reranking\
  -X POST \
  -d '{"initial_query":"What is Deep Learning?", "retrieved_docs": \
     [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Вхідними даними для мікросервісу є `initial_query` і список знайдених
документів, і він виводить найбільш релевантний документ до початкового запиту разом з іншими параметрами за замовчуванням, такими як температура, `repetition_penalty`, `chat_template` і так далі. Ми також можемо отримати перші n документів, задавши `top_n` як один із вхідних параметрів. Наприклад:

```
curl http://${host_ip}:8000/v1/reranking\
  -X POST \
  -d '{"initial_query":"What is Deep Learning?" ,"top_n":2, "retrieved_docs": \
     [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Ось результат:

```
{"id":"e1eb0e44f56059fc01aa0334b1dac313","query":"Human: Answer the question based only on the following context:\n    Deep learning is...\n    Question: What is Deep Learning?","max_new_tokens":1024,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}

```
Ви можете помітити, що мікросервіси ранжування мають стан ('ID' та інші метадані), в той час як сервіс переранжування не має.

### vLLM і TGI Service

```
curl http://${host_ip}:9009/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "Intel/neural-chat-7b-v3-3", \
     "prompt": "What is Deep Learning?", \
     "max_tokens": 32, "temperature": 0}'
```

Сервіс vLLM генерує текст для підказки введення. Ось очікуваний результат
від vllm:

```
{"generated_text":"We have all heard the buzzword, but our understanding of it is still growing. It’s a sub-field of Machine Learning, and it’s the cornerstone of today’s Machine Learning breakthroughs.\n\nDeep Learning makes machines act more like humans through their ability to generalize from very large"}
```

**Примітка**: Після запуску vLLM серверу vLLM потрібно кілька хвилин для завантаження моделювання та прогрів LLM.

```
curl http://${host_ip}:9009/generate \
  -X POST \
  -d '{"inputs":"What is Deep Learning?", \
     "parameters":{"max_new_tokens":17, "do_sample": true}}' \
  -H 'Content-Type: application/json'

```

Сервіс TGI генерує текст для підказки введення. Ось очікуваний результат від TGI:

```
{"generated_text":"We have all heard the buzzword, but our understanding of it is still growing. It’s a sub-field of Machine Learning, and it’s the cornerstone of today’s Machine Learning breakthroughs.\n\nDeep Learning makes machines act more like humans through their ability to generalize from very large"}
```

**Примітка**: Після запуску TGI серверу TGI потрібно кілька хвилин, щоб завантажити модель LLM і прогрітися.

Якщо ви отримали

```
curl: (7) Failed to connect to 100.81.104.168 port 8008 after 0 ms: Connection refused

```

і журнал показує, що модель прогрівається, будь ласка, зачекайте трохи і спробуйте пізніше.

```
2024-06-05T05:45:27.707509646Z 2024-06-05T05:45:27.707361Z  WARN text_generation_router: router/src/main.rs:357: `--revision` is not set
2024-06-05T05:45:27.707539740Z 2024-06-05T05:45:27.707379Z  WARN text_generation_router: router/src/main.rs:358: We strongly advise to set it to a known supported commit.
2024-06-05T05:45:27.852525522Z 2024-06-05T05:45:27.852437Z  INFO text_generation_router: router/src/main.rs:379: Serving revision bdd31cf498d13782cc7497cba5896996ce429f91 of model Intel/neural-chat-7b-v3-3
2024-06-05T05:45:27.867833811Z 2024-06-05T05:45:27.867759Z  INFO text_generation_router: router/src/main.rs:221: Warming up model

```

### Мікросервіс LLM

```
curl http://${host_ip}:9000/v1/chat/completions\
  -X POST \
  -d '{"query":"What is Deep Learning?","max_new_tokens":17,"top_k":10,"top_p":0.95,\
     "typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}' \
  -H 'Content-Type: application/json'

```

Ви отримаєте згенерований текст від LLM:

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

### Мегасервис

```
curl http://${host_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model": "Intel/neural-chat-7b-v3-3",
     "messages": "What is the revenue of Nike in 2023?"
     }'

```

Ось результат для вашого запросу:

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

## Перевірка журналу докер-контейнера 

Перевірте журнал контейнера:

`docker logs <CONTAINER ID> -t`


Перевірте журнал за посиланням  `docker logs f7a08f9867f9 -t`.

```
2024-06-05T01:30:30.695934928Z error: a value is required for '--model-id <MODEL_ID>' but none was supplied
2024-06-05T01:30:30.697123534Z
2024-06-05T01:30:30.697148330Z For more information, try '--help'.

```

Журнал показує, що `MODEL_ID` не встановлено.

Перегляньте вхідні параметри докера у файлі `./ChatQnA/docker_compose/intel/cpu/xeon/compose_vllm.yaml`.

```
vllm_service:
    image: ${REGISTRY:-opea}/vllm:${TAG:-latest}
    container_name: vllm-service
    ports:
      - "9009:80"
    volumes:
      - "./data:/data"
    shm_size: 128g
    environment:
      no_proxy: ${no_proxy}
      http_proxy: ${http_proxy}
      https_proxy: ${https_proxy}
      HF_TOKEN: ${HUGGINGFACEHUB_API_TOKEN}
      LLM_MODEL_ID: ${LLM_MODEL_ID}
    command: --model $LLM_MODEL_ID --host 0.0.0.0 --port 80

```

Перегляньте вхідні параметри докера у файлі `./ChatQnA/docker_compose/intel/cpu/xeon/compose.yaml`.

```
 tgi-service:
    image: ghcr.io/huggingface/text-generation-inference:sha-e4201f4-intel-cpu
    container_name: tgi-service
    ports:
      - "9009:80"
    volumes:
      - "./data:/data"
    shm_size: 1g
    environment:
      no_proxy: ${no_proxy}
      http_proxy: ${http_proxy}
      https_proxy: ${https_proxy}
      HF_TOKEN: ${HUGGINGFACEHUB_API_TOKEN}
      HF_HUB_DISABLE_PROGRESS_BARS: 1
      HF_HUB_ENABLE_HF_TRANSFER: 0
    command: --model-id ${LLM_MODEL_ID} --cuda-graphs 0

```

Вхідним значенням `MODEL_ID` є `${LLM_MODEL_ID}`.

Перевірте, щоб змінна оточення `LLM_MODEL_ID` була встановлена правильно, з правильним написанням.
Встановіть `LLM_MODEL_ID` і перезапустіть контейнери.

Також ви можете перевірити загальний журнал за допомогою наступної команди, де
compose.yaml - це файл конфігурації мегасервісу docker-compose.

```
docker compose -f ./docker_compose/intel/cpu/xeon/compose_vllm.yaml logs
```

```
docker compose -f ./docker_compose/intel/cpu/xeon/compose.yaml logs
```

## Запуск інтерфейсу користувача

### Базовий інтерфейс

Щоб отримати доступ до інтерфейсу, відкрийте в браузері наступну URL-адресу: http://{host_ip}:5173. За замовчуванням інтерфейс працює на внутрішньому порту 5173. Якщо ви бажаєте використовувати інший порт хоста для доступу до інтерфейсу, ви можете змінити мапінг портів у файлі compose.yaml, як показано нижче:
```
  chaqna-xeon-ui-server:
    image: opea/chatqna-ui:latest
    ...
    ports:
      - "80:5173"
```

### Діалоговий інтерфейс

Щоб отримати доступ до інтерфейсу діалогового інтерфейсу (заснованого на реакції), змініть сервіс інтерфейсу у файлі compose.yaml. Замініть сервіс chaqna-xeon-ui-server на сервіс chatqna-xeon-conversation-ui-server, як показано у конфігурації нижче:
```
chaqna-xeon-conversation-ui-server:
  image: opea/chatqna-conversation-ui:latest
  container_name: chatqna-xeon-conversation-ui-server
  environment:
    - APP_BACKEND_SERVICE_ENDPOINT=${BACKEND_SERVICE_ENDPOINT}
    - APP_DATA_PREP_SERVICE_URL=${DATAPREP_SERVICE_ENDPOINT}
  ports:
    - "5174:80"
  depends_on:
    - chaqna-xeon-backend-server
  ipc: host
  restart: always
```

Після запуску сервісів відкрийте у браузері наступну URL-адресу: http://{host_ip}:5174. За замовчуванням інтерфейс працює на внутрішньому порту 80. Якщо ви бажаєте використовувати інший порт хоста для доступу до інтерфейсу, ви можете змінити мапінг портів у файлі compose.yaml, як показано нижче:

```
  chaqna-xeon-conversation-ui-server:
    image: opea/chatqna-conversation-ui:latest
    ...
    ports:
      - "80:80"
```

### Зупинка сервісів

Після того, як ви закінчите роботу з усім трубопроводом і захочете зупинитися і видалити всі контейнери, скористайтеся командою, наведеною нижче:

```
docker compose -f compose_vllm.yaml down
```

```
docker compose -f compose.yaml down
```
