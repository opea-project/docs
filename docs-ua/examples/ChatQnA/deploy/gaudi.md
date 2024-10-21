# Одновузлове попереднє розгортання з vLLM або TGI на Gaudi AI Accelerator

У цьому розділі розгортання описано одновузлове попереднє розгортання ChatQnA
на прикладі комп'ютерів OPEA для розгортання за допомогою сервісу vLLM або TGI. Існує декілька
slice-n-dice способів увімкнути RAG з моделями vectordb та LLM, але тут ми
розглянемо один варіант для зручності: ми покажемо, як
побудувати e2e chatQnA з Redis VectorDB та моделлю neural-chat-7b-v3-3,
розгорнутої на Intel® Tiber™ Developer Cloud (ITDC). Для отримання додаткової інформації про те, як налаштувати екземпляр ITDC для подальшої роботи,
будь ласка, дотримуйтесь інструкцій тут (*** getting started section***). Якщо у вас
не маєте екземпляра ITDC або обладнання ще не підтримується в ITDC, ви все одно можете запустити його попередньо. Щоб запустити цю попередню версію, переконайтеся, що всі
(***system level requriements***), такі як версії докерів, версії драйверів тощо.

## Огляд

Існує декілька способів створити варіант використання ChatQnA. У цьому підручнику ми
розглянемо, як увімкнути наведений нижче список мікросервісів з OPEA
GenAIComps для розгортання одновузлового рішення vLLM або мегасервісу TGI.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with vLLM or TGI

Рішення має на меті показати, як використовувати Redis vectordb для RAG та
neural-chat-7b-v3-3 на Intel Gaudi AI Accelerator. Ми розглянемо
як налаштувати докер-контейнер для запуску мікросервісів і мегасервісів. Рішення буде використовувати зразок набору даних Nike у форматі PDF. Користувачі
можуть задати питання про Nike і отримати відповідь у вигляді чату за замовчуванням для до 1024 токенів. Рішення розгортається за допомогою інтерфейсу користувача. Існує 2 режими, які ви можете
використовувати:

1. Базовий інтерфейс
2. Діалоговий інтерфейс

Діалоговий інтерфейс не є обов'язковим, але підтримується у цьому прикладі, якщо ви зацікавлені у його використанні.

Підсумовуючи, нижче наведено зміст, який ми розглянемо в цьому посібнику:

1. Передумови
2. Підготовка (створення / витягування) образів Docker
3. Налаштування кейсів використання
4. Розгортання кейсу використання
5. Взаємодія з розгортанням ChatQnA

## Передумови

Перший крок - клонування GenAIExamples та GenAIComps. GenAIComps - це
фундаментальні необхідні компоненти, що використовуються для створення прикладів, які ви знайдете в GenAIExamples, і розгортання їх як мікросервісів.

```
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
```

Перевірте тег релізу
```
cd GenAIComps
git checkout tags/v1.0
```

У прикладах використовуються ваги моделей з HuggingFace і langchain.

Налаштуйте свій обліковий запис [HuggingFace](https://huggingface.co/) і згенеруйте [токен доступу користувача](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

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

## Підготовка (створення / витягування) образів Docker

Цей крок передбачає створення/витягування (можливо, у майбутньому) відповідних  докер-образів з покроковим описом процесу та перевіркою працездатності в кінці. Для
ChatQnA знадобляться такі докер-образи: embedding, retriever, rerank, LLM і dataprep. Крім того, вам потрібно буде зібрати докер-образи для мегасервісу ChatQnA та інтерфейсу користувача (розмовний React UI не є обов'язковим). Загалом
є 8 обов'язкових і один необов'язковий докер-образів.

Докер-образи, необхідні для встановлення прикладу, потрібно збирати локально, проте незабаром Intel викладе ці образи на докер-хаб.

### Створення/витягування образів мікросервісів

З папки `GenAIComps`.

#### Створення образу Dataprep

```bash
docker build --no-cache -t opea/dataprep-redis:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/dataprep/redis/langchain/Dockerfile .
```

#### Створення образу для вбудовування

```bash
docker build --no-cache -t opea/embedding-tei:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/embeddings/tei/langchain/Dockerfile .
```

#### Створення образу ретривера

```bash
docker build --no-cache -t opea/retriever-redis:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/retrievers/redis/langchain/Dockerfile .
```

#### Створення образу переранжування

```bash
docker build --no-cache -t opea/reranking-tei:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/reranks/tei/Dockerfile .
```

#### Збірка докера

Зберіть докер-образ vLLM з підтримкою hpu
```
docker build --no-cache -t opea/llm-vllm-hpu:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/vllm/langchain/dependency/Dockerfile.intel_hpu .
```

Створення образу vLLM Microservice
```
docker build --no-cache -t opea/llm-vllm:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/vllm/langchain/Dockerfile .
cd ..
```

```bash
docker build --no-cache -t opea/llm-tgi:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/tgi/Dockerfile .
```

### Побудувати образ TEI Гауді

Since a TEI Gaudi Docker image hasn't been published, we'll need to build it from the [tei-gaudi](https://github.com/huggingface/tei-gaudi) repository.

```bash
git clone https://github.com/huggingface/tei-gaudi
cd tei-gaudi/
docker build --no-cache -f Dockerfile-hpu -t opea/tei-gaudi:latest .
cd ..
```

### Створення образів Mega Service

Мегасервіс - це конвеєр, який передає дані через різні мікросервіси, кожен з яких виконує різні завдання. Ми визначаємо різні
мікросервіси і потік даних між ними у файлі `chatqna.py`, скажімо, у
цьому прикладі вихід мікросервісу вбудовування буде входом мікросервісу пошуку
який, у свою чергу, передасть дані мікросервісу ранжування і так далі.
Ви також можете додавати нові або видаляти деякі мікросервіси і налаштовувати
мегасервіс відповідно до потреб.

Створення образу мегасервісу для цього варіанту використання

```
cd ..
cd GenAIExamples
git checkout tags/v1.0
cd ChatQnA
```

```bash
docker build --no-cache -t opea/chatqna:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile .
cd ../..
```

### Створення образів інших сервісів

Якщо ви хочете увімкнути мікросервіс захисних бар'єрів у трубопроводі, будь ласка, використовуйте наведену нижче команду:

```bash
cd GenAIExamples/ChatQnA/
docker build --no-cache -t opea/chatqna-guardrails:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile.guardrails .
cd ../..
```

### Створення образу інтерфейсу користувача

Як вже було сказано, ви можете створити 2 режими інтерфейсу

*Базовий інтерфейс*

```bash
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-ui:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile .
cd ../../..
```

*Діалоговий інтерфейс*
Якщо ви хочете отримати розмовний досвід з мегасервісом chatqna.

```bash
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-conversation-ui:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile.react .
cd ../../..
```

### Перевірка здорового глузду.
Перед тим, як перейти до наступного кроку, перевірте, чи у вас є наведений нижче набір докер-образів:

* opea/dataprep-redis:latest
* opea/embedding-tei:latest
* opea/retriever-redis:latest
* opea/reranking-tei:latest
* opea/tei-gaudi:latest
* opea/chatqna:latest or opea/chatqna-guardrails:latest
* opea/chatqna:latest
* opea/chatqna-ui:latest
* opea/vllm:latest
* opea/llm-vllm:latest

* opea/dataprep-redis:latest
* opea/embedding-tei:latest
* opea/retriever-redis:latest
* opea/reranking-tei:latest
* opea/tei-gaudi:latest
* opea/chatqna:latest or opea/chatqna-guardrails:latest
* opea/chatqna-ui:latest
* opea/llm-tgi:latest

## Налаштування кейсу використання

Як вже згадувалося, у цьому прикладі використання буде використано наступну комбінацію GenAICompsз інструментами

|Компоненти кейсу використання | Інструменти |   Модель     | Тип сервісу |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   vLLM     |Intel/neural-chat-7b-v3-3 |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Інструменти і моделі, згадані у таблиці, налаштовуються або через змінну
або через змінну оточення чи файл `compose_vllm.yaml`.

|Компоненти кейсу використання | Інструменти |   Модель    | Тип сервісу |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   TGI        | Intel/neural-chat-7b-v3-3|OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Інструменти і моделі, згадані у таблиці, налаштовуються або через змінну
або через змінну оточення чи файл `compose.yaml`.

Встановіть необхідні змінні оточення для налаштування варіанту використання

> Примітка: Замініть `host_ip` на вашу зовнішню IP-адресу. **Не** використовуйте localhost
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
    export TEI_EMBEDDING_ENDPOINT="http://${host_ip}:8090"
    export tei_embedding_devices=all

### Reranking Service

    export RERANK_MODEL_ID="BAAI/bge-reranker-base"
    export TEI_RERANKING_ENDPOINT="http://${host_ip}:8808"
    export RERANK_SERVICE_HOST_IP=${host_ip}

### LLM Service

    export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
    export LLM_SERVICE_HOST_IP=${host_ip}
    export LLM_SERVICE_PORT=9000
    export vLLM_LLM_ENDPOINT="http://${host_ip}:8007"


    export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
    export LLM_SERVICE_HOST_IP=${host_ip}
    export LLM_SERVICE_PORT=9000
    export TGI_LLM_ENDPOINT="http://${host_ip}:8005"


    export llm_service_devices=all

### Megaservice

    export MEGA_SERVICE_HOST_IP=${host_ip}
    export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8888/v1/chatqna"

### Guardrails (optional)
Якщо у трубопроводі увімкнено мікросервіс Guardrails, необхідно встановити наведені нижче змінні оточення.
```
export GURADRAILS_MODEL_ID="meta-llama/Meta-Llama-Guard-2-8B"
export SAFETY_GUARD_MODEL_ID="meta-llama/Meta-Llama-Guard-2-8B"
export SAFETY_GUARD_ENDPOINT="http://${host_ip}:8088"
export GUARDRAIL_SERVICE_HOST_IP=${host_ip}
```
## Розгортання кейсу використання

У цьому посібнику ми будемо розгортати за допомогою docker compose з наданого
YAML-файлу. Інструкції docker compose повинні запустити всі вищезгадані сервіси як контейнери.

```
cd GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi
docker compose -f compose_vllm.yaml up -d
```

```
cd GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi
```

Скористайтеся ОДНИМ із наведених нижче способів.
1. Використовуйте TGI для бекенду LLM.

```bash
docker compose -f compose.yaml up -d
```

2. Увімкніть мікросервіс Guardrails у трубопроводі. Він буде використовувати сервіс TGI Guardrails.

```bash
docker compose -f compose_guardrails.yaml up -d
```

### Валідація мікросервісу
#### Перевірка змінних Env
Перевірте журнал запуску за допомогою `docker compose -f ./docker/docker_compose/intel/hpu/gaudi/compose_vllm.yaml logs`.

Попереджувальні повідомлення виводять змінні, якщо вони **НЕ** задані.

```bash
    ubuntu@xeon-vm:~/GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi$ docker compose -f ./compose_vllm.yaml up -d
    [+] Running 12/12
    ✔ Network gaudi_default                   Created                                                                        0.1s
    ✔ Container tei-embedding-gaudi-server    Started                                                                        1.3s
    ✔ Container vllm-gaudi-server             Started                                                                        1.3s
    ✔ Container tei-reranking-gaudi-server    Started                                                                        0.8s
    ✔ Container redis-vector-db               Started                                                                        0.7s
    ✔ Container reranking-tei-gaudi-server    Started                                                                        1.7s
    ✔ Container retriever-redis-server        Started                                                                        1.3s
    ✔ Container llm-vllm-gaudi-server         Started                                                                        2.1s
    ✔ Container dataprep-redis-server         Started                                                                        2.1s
    ✔ Container embedding-tei-server          Started                                                                        2.0s
    ✔ Container chatqna-gaudi-backend-server  Started                                                                        2.3s
    ✔ Container chatqna-gaudi-ui-server       Started                                                                        2.6s
```

```bash
    ubuntu@xeon-vm:~/GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi$ docker compose -f ./compose.yaml up -d
    [+] Running 12/12
    ✔ Network gaudi_default                   Created                                                                        0.1s
    ✔ Container tei-reranking-gaudi-server    Started                                                                        1.1s
    ✔ Container tgi-gaudi-server              Started                                                                        0.8s
    ✔ Container redis-vector-db               Started                                                                        1.5s
    ✔ Container tei-embedding-gaudi-server    Started                                                                        1.1s
    ✔ Container retriever-redis-server        Started                                                                        2.7s
    ✔ Container reranking-tei-gaudi-server    Started                                                                        2.0s
    ✔ Container dataprep-redis-server         Started                                                                        2.5s
    ✔ Container embedding-tei-server          Started                                                                        2.1s
    ✔ Container llm-tgi-gaudi-server          Started                                                                        1.8s
    ✔ Container chatqna-gaudi-backend-server  Started                                                                        2.9s
    ✔ Container chatqna-gaudi-ui-server       Started                                                                        3.3s
```

#### Перевірте статус контейнера

Перевірте, чи всі контейнери, запущені за допомогою docker compose, запущено

Наприклад, у прикладі ChatQnA запускається 11 докерів (сервісів), перевірте ці докер-контейнери запущено, тобто всі контейнери `STATUS` мають значення `Up`.
Для швидкої перевірки працездатності спробуйте `docker ps -a`, щоб побачити, чи всі контейнери запущено

```bash
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED              STATUS              PORTS                                                                                  NAMES
42c8d5ec67e9   opea/chatqna-ui:latest                                  "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:5173->5173/tcp, :::5173->5173/tcp                                              chatqna-gaudi-ui-server
7f7037a75f8b   opea/chatqna:latest                                     "python chatqna.py"      About a minute ago   Up About a minute   0.0.0.0:8888->8888/tcp, :::8888->8888/tcp                                              chatqna-gaudi-backend-server
4049c181da93   opea/embedding-tei:latest                               "python embedding_te…"   About a minute ago   Up About a minute   0.0.0.0:6000->6000/tcp, :::6000->6000/tcp                                              embedding-tei-server
171816f0a789   opea/dataprep-redis:latest                              "python prepare_doc_…"   About a minute ago   Up About a minute   0.0.0.0:6007->6007/tcp, :::6007->6007/tcp                                              dataprep-redis-server
10ee6dec7d37   opea/llm-vllm:latest                                    "bash entrypoint.sh"     About a minute ago   Up About a minute   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp                                              llm-vllm-gaudi-server
ce4e7802a371   opea/retriever-redis:latest                             "python retriever_re…"   About a minute ago   Up About a minute   0.0.0.0:7000->7000/tcp, :::7000->7000/tcp                                              retriever-redis-server
be6cd2d0ea38   opea/reranking-tei:latest                               "python reranking_te…"   About a minute ago   Up About a minute   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp                                              reranking-tei-gaudi-server
cc45ff032e8c   opea/tei-gaudi:latest                                   "text-embeddings-rou…"   About a minute ago   Up About a minute   0.0.0.0:8090->80/tcp, :::8090->80/tcp                                                  tei-embedding-gaudi-server
4969ec3aea02   opea/llm-vllm-hpu:latest                                "/bin/bash -c 'expor…"   About a minute ago   Up About a minute   0.0.0.0:8007->80/tcp, :::8007->80/tcp                                                  vllm-gaudi-server
0657cb66df78   redis/redis-stack:7.2.0-v9                              "/entrypoint.sh"         About a minute ago   Up About a minute   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp   redis-vector-db
684d3e9d204a   ghcr.io/huggingface/text-embeddings-inference:cpu-1.2   "text-embeddings-rou…"   About a minute ago   Up About a minute   0.0.0.0:8808->80/tcp, :::8808->80/tcp                                                  tei-reranking-gaudi-server
```

```bash
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED         STATUS         PORTS                                                                                  NAMES
0355d705484a   opea/chatqna-ui:latest                                  "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   0.0.0.0:5173->5173/tcp, :::5173->5173/tcp                                              chatqna-gaudi-ui-server
29a7a43abcef   opea/chatqna:latest                                     "python chatqna.py"      2 minutes ago   Up 2 minutes   0.0.0.0:8888->8888/tcp, :::8888->8888/tcp                                              chatqna-gaudi-backend-server
1eb6f5ad6f85   opea/llm-tgi:latest                                     "bash entrypoint.sh"     2 minutes ago   Up 2 minutes   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp                                              llm-tgi-gaudi-server
ad27729caf68   opea/reranking-tei:latest                               "python reranking_te…"   2 minutes ago   Up 2 minutes   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp                                              reranking-tei-gaudi-server
84f02cf2a904   opea/dataprep-redis:latest                              "python prepare_doc_…"   2 minutes ago   Up 2 minutes   0.0.0.0:6007->6007/tcp, :::6007->6007/tcp                                              dataprep-redis-server
367459f6e65b   opea/embedding-tei:latest                               "python embedding_te…"   2 minutes ago   Up 2 minutes   0.0.0.0:6000->6000/tcp, :::6000->6000/tcp                                              embedding-tei-server
8c78cde9f588   opea/retriever-redis:latest                             "python retriever_re…"   2 minutes ago   Up 2 minutes   0.0.0.0:7000->7000/tcp, :::7000->7000/tcp                                              retriever-redis-server
fa80772de92c   ghcr.io/huggingface/tgi-gaudi:2.0.1                     "text-generation-lau…"   2 minutes ago   Up 2 minutes   0.0.0.0:8005->80/tcp, :::8005->80/tcp                                                  tgi-gaudi-server
581687a2cc1a   opea/tei-gaudi:latest                                   "text-embeddings-rou…"   2 minutes ago   Up 2 minutes   0.0.0.0:8090->80/tcp, :::8090->80/tcp                                                  tei-embedding-gaudi-server
c59178629901   redis/redis-stack:7.2.0-v9                              "/entrypoint.sh"         2 minutes ago   Up 2 minutes   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp   redis-vector-db
5c3a78144498   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "text-embeddings-rou…"   2 minutes ago   Up 2 minutes   0.0.0.0:8808->80/tcp, :::8808->80/tcp                                                  tei-reranking-gaudi-server
```

## Взаємодія з розгортанням ChatQnA

У цьому розділі ви дізнаєтеся про різні способи взаємодії з
розгорнутими мікросервісами

### Dataprep Microservice（Optional）

Якщо ви хочете додати або оновити базу знань за замовчуванням, ви можете скористатися  командами нижче. Мікросервіс dataprep витягує тексти з різних джерел даних, розбиває дані на частини, вбудовує кожну частину за допомогою мікросервісу embedding і зберігає вбудовані вектори у базі даних векторів redis.

Завантаження локального файлу `nke-10k-2023.pdf`:

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

#### Видалення посилання
```
# Сервіс dataprep додасть постфікс .txt до файлу посилання

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

### TEI Embedding Service

Сервіс вбудовування TEI приймає на вхід рядок, вбудовує його у вектор певної довжини, визначеної моделлю вбудовування, і повертає цей вкладений вектор.

```
curl ${host_ip}:8090/embed \
    -X POST \
    -d '{"inputs":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json'
```

У цьому прикладі використовується модель вбудовування «BAAI/bge-base-en-v1.5», яка має розмір вектора 768. Отже, результатом виконання команди curl буде вбудований вектор довжиною 768.

### Embedding Microservice
Мікросервіс вбудовування залежить від сервісу вбудовування TEI. З точки зору
вхідних параметрів, він приймає рядок, вбудовує його у вектор за допомогою вбудовування TEI, додає інші параметри за замовчуванням, необхідні для мікросервісу пошуку і повертає його.

```
curl http://${host_ip}:6000/v1/embeddings\
  -X POST \
  -d '{"text":"hello"}' \
  -H 'Content-Type: application/json'
```
### Retriever Microservice

Щоб споживати мікросервіс retriever, потрібно згенерувати mock embedding
вектор за допомогою Python-скрипту. Довжина вектора вбудовування визначається
моделлю вбудовування. Тут ми використовуємо модель EMBEDDING_MODEL_ID=«BAAI/bge-base-en-v1.5», розмір вектора якої становить 768.

Перевірте векторну розмірність вашої моделі вбудовування і встановіть
розмірність `your_embedding` дорівнює їй.

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

### TEI Reranking Service

Сервіс переранжування TEI переранжує документи, повернуті пошуковою службою
сервісом. Вона споживає запит і список документів і повертає індекс документа на основі убування показника схожості. Документ
що відповідає повернутому індексу з найбільшою оцінкою, є найбільш релевантним для вхідного запиту.
```
curl http://${host_ip}:8808/rerank \
    -X POST \
    -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
    -H 'Content-Type: application/json'
```

Вивід:  `[{"index":1,"score":0.9988041},{"index":0,"score":0.022948774}]`


### Reranking Microservice

Мікросервіс переранжування використовує сервіс переранжування TEI і підставляє у відповідь параметрами за замовчуванням, необхідними для мікросервісу LLM.

```
curl http://${host_ip}:8000/v1/reranking \
  -X POST \
  -d '{"initial_query":"What is Deep Learning?", "retrieved_docs": [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Вхідними даними для мікросервісу є `initial_query` і список знайдених
документів, і він виводить найбільш релевантний документ до початкового запиту разом з іншими параметрами за замовчуванням, такими як температура, `repetition_penalty`, `chat_template` і так далі. Ми також можемо отримати перші n документів, задавши `top_n` як один із вхідних параметрів.
Наприклад:

```
curl http://${host_ip}:8000/v1/reranking \
  -X POST \
  -d '{"initial_query":"What is Deep Learning?" ,"top_n":2, "retrieved_docs": [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Ось результат:

```
{"id":"e1eb0e44f56059fc01aa0334b1dac313","query":"Human: Answer the question based only on the following context:\n    Deep learning is...\n    Question: What is Deep Learning?","max_new_tokens":1024,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}

```
Ви можете помітити, що мікросервіси ранжування мають стан ('ID' та інші метадані), в той час як сервіс переранжування не має.

### LLM Service

```
curl http://${host_ip}:8007/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
  "model": "Intel/neural-chat-7b-v3-3",
  "prompt": "What is Deep Learning?",
  "max_tokens": 32,
  "temperature": 0
  }'
```

Сервіс vLLM згенерує текст для підказки введення. Ось очікуваний результат
від vllm:

```
{"id":"cmpl-be8e1d681eb045f082a7b26d5dba42ff","object":"text_completion","created":1726269914,"model":"Intel/neural-chat-7b-v3-3","choices":[{"index":0,"text":"\n\nDeep Learning is a subset of Machine Learning that is concerned with algorithms inspired by the structure and function of the brain. It is a part of Artificial","logprobs":null,"finish_reason":"length","stop_reason":null}],"usage":{"prompt_tokens":6,"total_tokens":38,"completion_tokens":32}}d
```

**Примітка**: Після запуску vLLM серверу vLLM потрібно кілька хвилин для завантаження LLM моделі та прогрів.

```
curl http://${host_ip}:8005/generate \
  -X POST \
  -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":64, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

Сервіс TGI генерує текст для підказки введення. Ось очікуваний результат від TGI:

```
{"generated_text":"Artificial Intelligence (AI) has become a very popular buzzword in the tech industry. While the phrase conjures images of sentient robots and self-driving cars, our current AI landscape is much more subtle. In fact, it most often manifests in the forms of algorithms that help recognize the faces of"}
```

**Примітка**: Після запуску TGI серверу TGI потрібно кілька хвилин, щоб завантажити модель LLM і прогрітися.

Якщо ви отримали
```
curl: (7) Failed to connect to 100.81.104.168 port 8008 after 0 ms: Connection refused
```

і журнал показує, що модель прогрівається, будь ласка, зачекайте деякий час і спробуйте пізніше.

```
2024-06-05T05:45:27.707509646Z 2024-06-05T05:45:27.707361Z  WARN text_generation_router: router/src/main.rs:357: `--revision` is not set
2024-06-05T05:45:27.707539740Z 2024-06-05T05:45:27.707379Z  WARN text_generation_router: router/src/main.rs:358: We strongly advise to set it to a known supported commit.
2024-06-05T05:45:27.852525522Z 2024-06-05T05:45:27.852437Z  INFO text_generation_router: router/src/main.rs:379: Serving revision bdd31cf498d13782cc7497cba5896996ce429f91 of model Intel/neural-chat-7b-v3-3
2024-06-05T05:45:27.867833811Z 2024-06-05T05:45:27.867759Z  INFO text_generation_router: router/src/main.rs:221: Warming up model

```

### LLM Microservice

```
curl http://${host_ip}:9000/v1/chat/completions \
  -X POST \
  -d '{"query":"What is Deep Learning?","max_new_tokens":17,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}' \
  -H 'Content-Type: application/json'
```

Ви отримаєте згенерований текст від LLM:

```
data: b'\n'
data: b'\n'
data: b'Deep'
data: b' Learning'
data: b' is'
data: b' a'
data: b' subset'
data: b' of'
data: b' Machine'
data: b' Learning'
data: b' that'
data: b' is'
data: b' concerned'
data: b' with'
data: b' algorithms'
data: b' inspired'
data: b' by'
data: [DONE]
```

### MegaService

```
curl http://${host_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model": "Intel/neural-chat-7b-v3-3",
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

#### Guardrail Microservice
Якщо ви увімкнули мікросервіс Guardrail, зверніться до нього за допомогою наведеної нижче команди curl

```
curl http://${host_ip}:9090/v1/guardrails\
  -X POST \
  -d '{"text":"How do you buy a tiger in the US?","parameters":{"max_new_tokens":32}}' \
  -H 'Content-Type: application/json'
```

## Запуск інтерфейсу користувача
### Базовий інтерфейс
To access the frontend, open the following URL in your browser: http://{host_ip}:5173. By default, the UI runs on port 5173 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the compose.yaml file as shown below:
```bash
  chaqna-gaudi-ui-server:
    image: opea/chatqna-ui:latest
    ...
    ports:
      - "80:5173"
```

### Діалоговий інтерфейс
Щоб отримати доступ до діалогового інтерфейсу (заснованого на реакції), змініть службу інтерфейсу у файлі compose.yaml. Замініть службу chaqna-gaudi-ui-server на службу chatqna-gaudi-conversation-ui-server, як показано у конфігурації нижче:
```bash
chaqna-gaudi-conversation-ui-server:
  image: opea/chatqna-conversation-ui:latest
  container_name: chatqna-gaudi-conversation-ui-server
  environment:
    - APP_BACKEND_SERVICE_ENDPOINT=${BACKEND_SERVICE_ENDPOINT}
    - APP_DATA_PREP_SERVICE_URL=${DATAPREP_SERVICE_ENDPOINT}
  ports:
    - "5174:80"
  depends_on:
    - chaqna-gaudi-backend-server
  ipc: host
  restart: always
```
Після запуску служб відкрийте у браузері наступну URL-адресу: http://{host_ip}:5174. За замовчуванням інтерфейс працює на внутрішньому порту 80. Якщо ви бажаєте використовувати інший порт хоста для доступу до інтерфейсу, ви можете змінити мапінг портів у файлі compose.yaml, як показано нижче:
```
  chaqna-gaudi-conversation-ui-server:
    image: opea/chatqna-conversation-ui:latest
    ...
    ports:
      - "80:80"
```

## Перевірка журналу докер-контейнера

Перевірте журнал контейнера:

`docker logs <CONTAINER ID> -t`


Перевірте журнал  `docker logs f7a08f9867f9 -t`.

```
2024-06-05T01:30:30.695934928Z error: a value is required for '--model-id <MODEL_ID>' but none was supplied
2024-06-05T01:30:30.697123534Z
2024-06-05T01:30:30.697148330Z For more information, try '--help'.

```

Журнал показує, що `MODEL_ID` не встановлено.

Переглянути вхідні параметри докера можна у файлі `./ChatQnA/docker_compose/intel/hpu/gaudi/compose_vllm.yaml`.

```yaml
  vllm-service:
    image: ${REGISTRY:-opea}/llm-vllm-hpu:${TAG:-latest}
    container_name: vllm-gaudi-server
    ports:
      - "8007:80"
    volumes:
      - "./data:/data"
    environment:
      no_proxy: ${no_proxy}
      http_proxy: ${http_proxy}
      https_proxy: ${https_proxy}
      HF_TOKEN: ${HUGGINGFACEHUB_API_TOKEN}
      HABANA_VISIBLE_DEVICES: all
      OMPI_MCA_btl_vader_single_copy_mechanism: none
      LLM_MODEL_ID: ${LLM_MODEL_ID}
    runtime: habana
    cap_add:
      - SYS_NICE
    ipc: host
    command: /bin/bash -c "export VLLM_CPU_KVCACHE_SPACE=40 && python3 -m vllm.entrypoints.openai.api_server --enforce-eager --model $LLM_MODEL_ID --tensor-parallel-size 1 --host 0.0.0.0 --port 80 --block-size 128 --max-num-seqs 256 --max-seq_len-to-capture 2048"
```

Переглянути вхідні параметри докера можна у файлі `./ChatQnA/docker_compose/intel/hpu/gaudi/compose.yaml`

```yaml
  tgi-service:
    image: ghcr.io/huggingface/tgi-gaudi:2.0.1
    container_name: tgi-gaudi-server
    ports:
      - "8005:80"
    volumes:
      - "./data:/data"
    environment:
      no_proxy: ${no_proxy}
      http_proxy: ${http_proxy}
      https_proxy: ${https_proxy}
      HF_TOKEN: ${HUGGINGFACEHUB_API_TOKEN}
      HF_HUB_DISABLE_PROGRESS_BARS: 1
      HF_HUB_ENABLE_HF_TRANSFER: 0
      HABANA_VISIBLE_DEVICES: ${llm_service_devices}
      OMPI_MCA_btl_vader_single_copy_mechanism: none
    runtime: habana
    cap_add:
      - SYS_NICE
    ipc: host
    command: --model-id ${LLM_MODEL_ID} --max-input-length 1024 --max-total-tokens 2048
```

Вхідним значенням `MODEL_ID` є `${LLM_MODEL_ID}`.

Перевірте, щоб змінна оточення `LLM_MODEL_ID` була встановлена коректно, з правильним написанням.
Встановіть `LLM_MODEL_ID` і перезапустіть контейнери.

Також ви можете перевірити загальний журнал за допомогою наступної команди, де
compose.yaml - це файл конфігурації мегасервісу docker-compose.

```
docker compose -f ./docker_compose/intel/hpu/gaudi/compose_vllm.yaml logs
```

```
docker compose -f ./docker_compose/intel/hpu/gaudi/compose.yaml logs
```

## Запуск інтерфейсу користувача

### Базовий інтерфейс

Щоб отримати доступ до інтерфейсу, відкрийте в браузері наступну URL-адресу: http://{host_ip}:5173. За замовчуванням інтерфейс працює на внутрішньому порту 5173. Якщо ви бажаєте використовувати інший порт хоста для доступу до інтерфейсу, ви можете змінити мапінг портів у файлі compose.yaml, як показано нижче:
```
  chaqna-gaudi-ui-server:
    image: opea/chatqna-ui:latest
    ...
    ports:
      - "80:5173"
```

### Діалоговий інтерфейс

Щоб отримати доступ до розмовного інтерфейсу (заснованого на реакції), змініть службу інтерфейсу у файлі compose.yaml. Замініть службу chaqna-gaudi-ui-server на службу chatqna-gaudi-conversation-ui-server, як показано у конфігурації нижче:
```
chaqna-gaudi-conversation-ui-server:
  image: opea/chatqna-conversation-ui:latest
  container_name: chatqna-gaudi-conversation-ui-server
  environment:
    - APP_BACKEND_SERVICE_ENDPOINT=${BACKEND_SERVICE_ENDPOINT}
    - APP_DATA_PREP_SERVICE_URL=${DATAPREP_SERVICE_ENDPOINT}
  ports:
    - "5174:80"
  depends_on:
    - chaqna-gaudi-backend-server
  ipc: host
  restart: always
```

Після запуску служб відкрийте у браузері наступну URL-адресу: http://{host_ip}:5174. За замовчуванням інтерфейс працює на внутрішньому порту 80. Якщо ви бажаєте використовувати інший порт хоста для доступу до інтерфейсу, ви можете змінити мапінг портів у файлі compose.yaml, як показано нижче:

```
  chaqna-gaudi-conversation-ui-server:
    image: opea/chatqna-conversation-ui:latest
    ...
    ports:
      - "80:80"
```

### Зупинити роботу сервісів

Після того, як ви закінчите роботу з усім трубопроводом і захочете зупинитися і видалити всі контейнери, скористайтеся командою, наведеною нижче:

```
docker compose -f compose_vllm.yaml down
```

```
docker compose -f compose.yaml down
```
