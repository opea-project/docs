# Single node on-prem deployment with Ollama on AIPC

This deployment section covers single-node on-prem deployment of the ChatQnA
example with OPEA comps to deploy using Ollama. There are several
slice-n-dice ways to enable RAG with vectordb and LLM models, but here we will
be covering one option of doing it for convenience : we will be showcasing  how
to build an e2e chatQnA with Redis VectorDB and the llama-3 model,
deployed on the client CPU.  
## Overview

There are several ways to setup a ChatQnA use case. Here in this tutorial, we
will walk through how to enable the below list of microservices from OPEA
GenAIComps to deploy a single node Ollama megaservice solution.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with Ollama

The solution is aimed to show how to use Redis vectordb for RAG and 
the llama-3 model on Intel Client PCs. We will go through 
how to setup docker container to start microservices and megaservice. 
The solution will then utilize a sample Nike dataset which is in PDF format. Users 
can then ask a question about Nike and get a chat-like response by default for 
up to 1024 tokens. The solution is deployed with a UI. There are 2 modes you can use:
1. Basic UI
2. Conversational UI

Conversational UI is optional, but a feature supported in this example if you are interested to use.

## Prerequisites 

First step is to clone the GenAIExamples and GenAIComps. GenAIComps are 
fundamental necessary components used to build examples you find in 
GenAIExamples and deploy them as microservices.

```
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
```

Checkout the release tag
```
cd GenAIComps
git checkout tags/v1.0
```

The examples utilize model weights from Ollama and langchain.

Setup your [HuggingFace](https://huggingface.co/) account and generate
[user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Setup the HuggingFace token
```
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

The example requires you to set the `host_ip` to deploy the microservices on
endpoint enabled with ports. Set the host_ip env variable
```
export host_ip=$(hostname -I | awk '{print $1}')
```

Make sure to setup Proxies if you are behind a firewall
```
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Prepare (Building / Pulling) Docker images

This step will involve building/pulling ( maybe in future) relevant docker
images with step-by-step process along with sanity check in the end. For
ChatQnA, the following docker images will be needed: embedding, retriever,
rerank, LLM and dataprep. Additionally, you will need to build docker images for
ChatQnA megaservice, and UI (conversational React UI is optional). In total,
there are 8 required and an optional docker images.

The docker images needed to setup the example needs to be build local, however
the images will be pushed to docker hub soon by Intel.

### Build/Pull Microservice images

From within the `GenAIComps` folder

#### Build Dataprep Image

```
docker build --no-cache -t opea/dataprep-redis:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/dataprep/redis/langchain/Dockerfile .
```

#### Build Embedding Image

```
docker build --no-cache -t opea/embedding-tei:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/embeddings/tei/langchain/Dockerfile .
```

#### Build Retriever Image

```
 docker build --no-cache -t opea/retriever-redis:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/retrievers/redis/langchain/Dockerfile .
```

#### Build Rerank Image

```
docker build --no-cache -t opea/reranking-tei:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f comps/reranks/tei/Dockerfile .
```

#### Build LLM Image

::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama

We set up the Ollama LLM service with one command
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Next, we'll build the Ollama microservice docker. This will set the entry point
needed for Ollama to suit the ChatQnA examples
```
docker build --no-cache -t opea/llm-ollama:latest --build-arg https_proxy=$https_proxy \
   --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/ollama/langchain/Dockerfile .
```

Set Ollama Service Configuration

Ollama Service Configuration file is `/etc/systemd/system/ollama.service`.
Edit the file to set OLLAMA_HOST environment (Replace **${host_ip}** with your host IPV4).
```
Environment="OLLAMA_HOST=${host_ip}:11434"
```
Set https_proxy environment for Ollama if your system access network through proxy.
```
Environment="https_proxy=http://proxy.example.com:8080"
```
Restart Ollama services
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
:::
::::



### Build Mega Service images

The Megaservice is a pipeline that channels data through different
microservices, each performing varied tasks. We define the different
microservices and the flow of data between them in the `chatqna.py` file, say in
this example the output of embedding microservice will be the input of retrieval
microservice which will in turn passes data to the reranking microservice and so
on. You can also add newer or remove some microservices and customize the
megaservice to suit the needs.

Build the megaservice image for this use case

```
cd ..
cd GenAIExamples/ChatQnA
git checkout tags/v1.0
```

```
docker build --no-cache -t opea/chatqna:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f Dockerfile .
```

### Build Other Service images

#### Build the UI Image

As mentioned, you can build 2 modes of UI

*Basic UI*

```
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-ui:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile .
```

*Conversation UI*
If you want a conversational experience with chatqna megaservice.

```
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-conversation-ui:latest --build-arg https_proxy=$https_proxy \
  --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile.react .
```

### Sanity Check
Check if you have the below set of docker images, before moving on to the next step:

::::{tab-set}
:::{tab-item} Ollama
:sync: Ollama

* opea/dataprep-redis:latest
* opea/embedding-tei:latest
* opea/retriever-redis:latest
* opea/reranking-tei:latest
* opea/llm-ollama:latest
* opea/chatqna:latest
* opea/chatqna-ui:latest
:::

::::




## Use Case Setup

As mentioned the use case will use the following combination of the GenAIComps
with the tools

::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama

|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   Ollama     | llama3                   |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Tools and models mentioned in the table are configurable either through the
environment variable or `compose.yaml` file.
:::
::::

Set the necessary environment variables to setup the use case case

> Note: Replace `host_ip` with your external IP address. Do **NOT** use localhost
> for the below set of environment variables

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
::::{tab-set}
:::{tab-item} Ollama
:sync: Ollama

    export LLM_SERVICE_HOST_IP=${host_ip}
    export OLLAMA_ENDPOINT=http://${host_ip}:11434
    export OLLAMA_MODEL="llama3"
:::
::::

### Megaservice

    export MEGA_SERVICE_HOST_IP=${host_ip}
    export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8888/v1/chatqna"

## Deploy the use case

In this tutorial, we will be deploying via docker compose with the provided
YAML file.  The docker compose instructions should be starting all the
above mentioned services as containers.

::::{tab-set}
:::{tab-item} Ollama
:sync: Ollama

```
cd GenAIExamples/ChatQnA/docker_compose/intel/cpu/aipc
docker compose -f compose.yaml up -d
```
:::
::::


### Validate microservice 

#### Check Env Variables
Check the start up log by `docker compose -f ./compose.yaml logs`.
The warning messages print out the variables if they are **NOT** set.

::::{tab-set}
:::{tab-item} Ollama
:sync: Ollama

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
:::
::::

#### Check the container status

Check if all the containers  launched via docker compose has started

For example, the ChatQnA example starts 11 docker (services), check these docker
containers are all running, i.e, all the containers  `STATUS`  are  `Up`
To do a quick sanity check, try `docker ps -a` to see if all the containers are running

::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama

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
:::
::::

## Interacting with ChatQnA deployment

This section will walk you through what are the different ways to interact with
the microservices deployed

### Dataprep Microservice（Optional）

If you want to add/update the default knowledge base, you can use the following
commands. The dataprep microservice extracts the texts from variety of data
sources, chunks the data, embeds each chunk using embedding microservice and
store the embedded vectors in the redis vector database.

Local File `nke-10k-2023.pdf` Upload:

```
curl -X POST "http://${host_ip}:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F "files=@./nke-10k-2023.pdf"
```

This command updates a knowledge base by uploading a local file for processing.
Update the file path according to your environment.

Add Knowledge Base via HTTP Links:

```
curl -X POST "http://${host_ip}:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F 'link_list=["https://opea.dev"]'
```

This command updates a knowledge base by submitting a list of HTTP links for processing.

Also, you are able to get the file list that you uploaded:

```
curl -X POST "http://${host_ip}:6007/v1/dataprep/get_file" \
     -H "Content-Type: application/json"

```

To delete the file/link you uploaded you can use the following commands:

#### Delete link
```
# The dataprep service will add a .txt postfix for link file

curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "https://opea.dev.txt"}' \
     -H "Content-Type: application/json"
```

#### Delete file

```
curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "nke-10k-2023.pdf"}' \
     -H "Content-Type: application/json"
```

#### Delete all uploaded files and links

```
curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "all"}' \
     -H "Content-Type: application/json"
```
### TEI Embedding Service

The TEI embedding service takes in a string as input, embeds the string into a
vector of a specific length determined by the embedding model and returns this
embedded vector.

```
curl ${host_ip}:6006/embed \
    -X POST \
    -d '{"inputs":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json'
```

In this example the embedding model used is "BAAI/bge-base-en-v1.5", which has a
vector size of 768. So the output of the curl command is a embedded vector of
length 768.

### Embedding Microservice
The embedding microservice depends on the TEI embedding service. In terms of
input parameters, it takes in a string, embeds it into a vector using the TEI
embedding service and adds other default parameters that are required for the
retrieval microservice and returns it.

```
curl http://${host_ip}:6000/v1/embeddings\
  -X POST \
  -d '{"text":"hello"}' \
  -H 'Content-Type: application/json'
```
### Retriever Microservice

To consume the retriever microservice, you need to generate a mock embedding
vector using Python script. The length of embedding vector is determined by the
embedding model. Here we use the
model EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5", which vector size is 768.

Check the vector dimension of your embedding model and set
`your_embedding` dimension equal to it.

```
export your_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")

curl http://${host_ip}:7000/v1/retrieval \
  -X POST \
  -d "{\"text\":\"test\",\"embedding\":${your_embedding}}" \
  -H 'Content-Type: application/json'

```
The output of the retriever microservice comprises of the a unique id for the
request, initial query or the input to the retrieval microservice, a list of top
`n` retrieved documents relevant to the input query, and top_n where n refers to
the number of documents to be returned.
The output is retrieved text that relevant to the input data:
```
{"id":"27210945c7c6c054fa7355bdd4cde818","retrieved_docs":[{"id":"0c1dd04b31ab87a5468d65f98e33a9f6","text":"Company: Nike. financial instruments are subject to master netting arrangements that allow for the offset of assets and liabilities in the event of default or early termination of the contract.\nAny amounts of cash collateral received related to these instruments associated with the Company's credit-related contingent features are recorded in Cash and\nequivalents and Accrued liabilities, the latter of which would further offset against the Company's derivative asset balance. Any amounts of cash collateral posted related\nto these instruments associated with the Company's credit-related contingent features are recorded in Prepaid expenses and other current assets, which would further\noffset against the Company's derivative liability balance. Cash collateral received or posted related to the Company's credit-related contingent features is presented in the\nCash provided by operations component of the Consolidated Statements of Cash Flows. The Company does not recognize amounts of non-cash collateral received, such\nas securities, on the Consolidated Balance Sheets. For further information related to credit risk, refer to Note 12 — Risk Management and Derivatives.\n2023 FORM 10-K 68Table of Contents\nThe following tables present information about the Company's derivative assets and liabilities measured at fair value on a recurring basis and indicate the level in the fair\nvalue hierarchy in which the Company classifies the fair value measurement:\nMAY 31, 2023\nDERIVATIVE ASSETS\nDERIVATIVE LIABILITIES"},{"id":"1d742199fb1a86aa8c3f7bcd580d94af","text": ... }

```

### TEI Reranking Service

The TEI Reranking Service reranks the documents returned by the retrieval
service. It consumes the query and list of documents and returns the document
index based on decreasing order of the similarity score. The document
corresponding to the returned index with the highest score is the most relevant
document for the input query.
```
curl http://${host_ip}:8808/rerank \
    -X POST \
    -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
    -H 'Content-Type: application/json'
```

Output is:  `[{"index":1,"score":0.9988041},{"index":0,"score":0.022948774}]`


### Reranking Microservice


The reranking microservice consumes the TEI Reranking service and pads the
response with default parameters required for the LLM microservice.

```
curl http://${host_ip}:8000/v1/reranking\
  -X POST \
  -d '{"initial_query":"What is Deep Learning?", "retrieved_docs": \
     [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

The input to the microservice is the `initial_query` and a list of retrieved
documents and it outputs the most relevant document to the initial query along
with other default parameter such as the temperature, `repetition_penalty`,
`chat_template` and so on. We can also get top n documents by setting `top_n` as one
of the input parameters. For example:

```
curl http://${host_ip}:8000/v1/reranking\
  -X POST \
  -d '{"initial_query":"What is Deep Learning?" ,"top_n":2, "retrieved_docs": \
     [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Here is the output:

```
{"id":"e1eb0e44f56059fc01aa0334b1dac313","query":"Human: Answer the question based only on the following context:\n    Deep learning is...\n    Question: What is Deep Learning?","max_new_tokens":1024,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}

```
You may notice reranking microservice are with state ('ID' and other meta data),
while reranking service are not.

### Ollama Service

::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama

```
curl http://${host_ip}:11434/api/generate -d '{"model": "llama3", "prompt":"What is Deep Learning?"}'
```

Ollama service generates text for the input prompt. Here is the expected result
from Ollama:

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

:::
::::



### LLM Microservice
```
curl http://${host_ip}:9000/v1/chat/completions\
  -X POST \
  -d '{"query":"What is Deep Learning?","max_new_tokens":17,"top_k":10,"top_p":0.95,\
     "typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}' \
  -H 'Content-Type: application/json'

```

You will get the below generated text from LLM:

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

Here is the output for your reference:

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

## Check docker container log

Check the log of container by:

`docker logs <CONTAINER ID> -t`


Check the log by  `docker logs f7a08f9867f9 -t`.






Also you can check overall logs with the following command, where the
compose.yaml is the mega service docker-compose configuration file.


::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama

```
docker compose -f ./docker_compose/intel/cpu/apic/compose.yaml logs
```
:::
::::

## Launch UI

### Basic UI

To access the frontend, open the following URL in your browser: http://{host_ip}:5173. By default, the UI runs on port 5173 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the compose.yaml file as shown below:
```
  chaqna-aipc-ui-server:
    image: opea/chatqna-ui:latest
    ...
    ports:
      - "80:5173"
```

### Conversational UI

To access the Conversational UI (react based) frontend, modify the UI service in the compose.yaml file. Replace chaqna-aipc-ui-server service with the chatqna-aipc-conversation-ui-server service as per the config below:
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

Once the services are up, open the following URL in your browser: http://{host_ip}:5174. By default, the UI runs on port 80 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the compose.yaml file as shown below:

```
  chaqna-aipc-conversation-ui-server:
    image: opea/chatqna-conversation-ui:latest
    ...
    ports:
      - "80:80"
```

### Stop the services

Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:
::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama

```
docker compose -f compose.yaml down
```
:::
::::
