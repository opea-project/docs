# Single node on-prem deployment with vLLM or TGI on Xeon Scalable processors

This deployment section covers single-node on-prem deployment of the ChatQnA example using the vLLM or TGI LLM service. There are several ways to enable RAG with vectordb and LLM models, but this tutorial will be covering how to build an end-to-end ChatQnA pipeline with the Redis vector database and meta-llama/Meta-Llama-3-8B-Instruct model deployed on Intel® Xeon® Scalable processors. To quickly learn about OPEA and set up the required hardware and software, follow the instructions in the [Getting Started Guide](../../../getting-started/README.md).

## Overview

The list of microservices from OPEA GenAIComps are used to deploy a single node vLLM or TGI megaservice solution for ChatQnA.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with vLLM or TGI

The solution is aimed to show how to use Redis vectorDB for RAG and Meta-Llama-3-8B-Instruct model for LLM inference on Intel® Xeon® Scalable processors. Steps will include setting up docker containers, utilizing a sample Nike dataset in PDF format, and asking a question about Nike to get a response. There are 2 modes of UI that can be deployed:

1. Basic UI
2. Conversational UI

## Prerequisites

The first step is to clone the [GenAIExamples](https://github.com/opea-project/GenAIExamples) GitHub repo. Set a workspace path and the desired release version with the **number only** (i.e. 1.0, 1.1, etc) and checkout that version using the tag. 

```bash
# Set workspace
export WORKSPACE=<Path>
cd $WORKSPACE

# Set desired release version - number only
export RELEASE_VERSION=<Release_Version>

# GenAIExamples
git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples
git checkout tags/v${RELEASE_VERSION}
cd ..
```

Set up the HuggingFace token:
```bash
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

The example requires setting the `host_ip` to "localhost" to deploy the microservices on endpoints enabled with ports.
```bash
export host_ip="localhost"
```

For machines behind a firewall, set up the proxy environment variables:
```bash
export http_proxy="Your_HTTP_Proxy"
export https_proxy="Your_HTTPs_Proxy"
# Example: no_proxy="localhost, 127.0.0.1, 192.168.1.1"
export no_proxy="Your_No_Proxy",chatqna-xeon-ui-server,chatqna-xeon-backend-server,dataprep-redis-service,tei-embedding-service,retriever,tei-reranking-service,tgi-service,vllm-service
```

## Use Case Setup

ChatQnA will use the following GenAIComps and corresponding tools. Tools and models mentioned in the table are configurable either through environment variables in the `set_env.sh` or `compose.yaml` file.

::::{tab-set}

:::{tab-item} vllm
:sync: vllm

|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       | OPEA Microservice |
|VectorDB             |  Redis       | NA                       | Open source service |
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    | OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   vLLM       | meta-llama/Meta-Llama-3-8B-Instruct | OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

:::
:::{tab-item} TGI
:sync: TGI

|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       | OPEA Microservice |
|VectorDB             |  Redis       | NA                       | Open source service |
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    | OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   TGI        | meta-llama/Meta-Llama-3-8B-Instruct | OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

:::
::::

Set the necessary environment variables to set up the use case. To swap out models, modify `set_env.sh` before running it. For example, the environment variable `LLM_MODEL_ID` can be changed to another model by specifying the HuggingFace model card ID. 

```bash
cd $WORKSPACE/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon
source ./set_env.sh
```

## Deploy the use case

Run `docker compose` with the provided YAML file to start all the services mentioned above as containers.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
docker compose -f compose.yaml up -d
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
docker compose -f compose_tgi.yaml up -d
```
:::
::::

### Check Env Variables
After running `docker compose`, check for warning messages for environment variables that are **NOT** set. Address them if needed. 

::::{tab-set}
:::{tab-item} vllm
:sync: vllm
    ubuntu@xeon-vm:~/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon$ docker compose -f compose.yaml up -d
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] /home/ubuntu/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon/compose.yaml: `version` is obsolete
:::

:::{tab-item} TGI
:sync: TGI

    ubuntu@xeon-vm:~/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon$ docker compose -f compose_tgi.yaml up -d
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] /home/ubuntu/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon/compose_tgi.yaml: `version` is obsolete
:::
::::

### Check container statuses

Check if all the containers launched via `docker compose` are running i.e. each container's `STATUS` is `Up` and `Healthy`.

Run this command to see this info:
```bash
docker ps -a
```

The sample output is for OPEA release v1.2.

::::{tab-set}

:::{tab-item} vllm
:sync: vllm

```bash
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED          STATUS                      PORTS                                                                                      NAMES
25964cd40c51   opea/nginx:1.2                                          "/docker-entrypoint.…"   37 minutes ago   Up 37 minutes               0.0.0.0:80->80/tcp, [::]:80->80/tcp                                                        chatqna-xeon-nginx-server
bca19cf35370   opea/chatqna-ui:1.2                                     "docker-entrypoint.s…"   37 minutes ago   Up 37 minutes               0.0.0.0:5173->5173/tcp, [::]:5173->5173/tcp                                                chatqna-xeon-ui-server
e9622436428a   opea/chatqna:1.2                                        "python chatqna.py"      37 minutes ago   Up 37 minutes               0.0.0.0:8888->8888/tcp, [::]:8888->8888/tcp                                                chatqna-xeon-backend-server
514acfb8f398   opea/dataprep:1.2                                       "sh -c 'python $( [ …"   37 minutes ago   Up 37 minutes               0.0.0.0:6007->5000/tcp, [::]:6007->5000/tcp                                                dataprep-redis-server
dbaf2116ae4b   opea/retriever:1.2                                      "python opea_retriev…"   37 minutes ago   Up 37 minutes               0.0.0.0:7000->7000/tcp, [::]:7000->7000/tcp                                                retriever-redis-server
82d802dd79c0   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "text-embeddings-rou…"   37 minutes ago   Up 37 minutes               0.0.0.0:8808->80/tcp, [::]:8808->80/tcp                                                    tei-reranking-server
20aebf41b92b   opea/vllm:1.2                                           "python3 -m vllm.ent…"   37 minutes ago   Up 37 minutes (unhealthy)   0.0.0.0:9009->80/tcp, [::]:9009->80/tcp                                                    vllm-service
590ee468e4b7   redis/redis-stack:7.2.0-v9                              "/entrypoint.sh"         37 minutes ago   Up 37 minutes               0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp, 0.0.0.0:8001->8001/tcp, [::]:8001->8001/tcp   redis-vector-db
df543e8425ea   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "text-embeddings-rou…"   37 minutes ago   Up 37 minutes               0.0.0.0:6006->80/tcp, [::]:6006->80/tcp                                                    tei-embedding-server
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
CONTAINER ID   IMAGE                                                           COMMAND                  CREATED         STATUS         PORTS                                                                                      NAMES
f303bf48dd43   opea/nginx:1.2                                                  "/docker-entrypoint.…"   4 seconds ago   Up 3 seconds   0.0.0.0:80->80/tcp, [::]:80->80/tcp                                                        chatqna-xeon-nginx-server
0a2597a4baa0   opea/chatqna-ui:1.2                                             "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds   0.0.0.0:5173->5173/tcp, [::]:5173->5173/tcp                                                chatqna-xeon-ui-server
5b5a37ba59ed   opea/chatqna:1.2                                                "python chatqna.py"      4 seconds ago   Up 3 seconds   0.0.0.0:8888->8888/tcp, [::]:8888->8888/tcp                                                chatqna-xeon-backend-server
b2ec04f4d3d5   opea/dataprep:1.2                                               "sh -c 'python $( [ …"   4 seconds ago   Up 3 seconds   0.0.0.0:6007->5000/tcp, [::]:6007->5000/tcp                                                dataprep-redis-server
c6347c8758e4   opea/retriever:1.2                                              "python opea_retriev…"   4 seconds ago   Up 3 seconds   0.0.0.0:7000->7000/tcp, [::]:7000->7000/tcp                                                retriever-redis-server
13403b62e768   ghcr.io/huggingface/text-generation-inference:2.4.0-intel-cpu   "text-generation-lau…"   4 seconds ago   Up 3 seconds   0.0.0.0:9009->80/tcp, [::]:9009->80/tcp                                                    tgi-service
00509c41487b   redis/redis-stack:7.2.0-v9                                      "/entrypoint.sh"         4 seconds ago   Up 3 seconds   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp, 0.0.0.0:8001->8001/tcp, [::]:8001->8001/tcp   redis-vector-db
3e6e650f73a9   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5           "text-embeddings-rou…"   4 seconds ago   Up 3 seconds   0.0.0.0:8808->80/tcp, [::]:8808->80/tcp                                                    tei-reranking-server
105d130b80ac   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5           "text-embeddings-rou…"   4 seconds ago   Up 3 seconds   0.0.0.0:6006->80/tcp, [::]:6006->80/tcp                                                    tei-embedding-server
```
:::
::::

Each docker container's log can also be checked using:

```bash
docker logs <CONTAINER_ID OR CONTAINER_NAME>
```

## Validate microservices

This section will walk through the different ways to interact with the microservices deployed.

### TEI Embedding Service

The TEI embedding service takes in a string as input, embeds the string into a vector of a specific length determined by the embedding model, and returns this vector.

```bash
curl ${host_ip}:6006/embed \
    -X POST \
    -d '{"inputs":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json'
```

In this example, the embedding model used is `BAAI/bge-base-en-v1.5`, which has a vector size of 768. Therefore, the output of the curl command is a vector of length 768.

### Retriever Microservice

To consume the retriever microservice, generate a mock embedding vector with a Python script. The length of the embedding vector is determined by the embedding model. The model is set with the environment variable EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5", which has a vector size of 768.

Check the vector dimension of the embedding model used and set `your_embedding` dimension equal to it.

```bash
export your_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")

curl http://${host_ip}:7000/v1/retrieval \
  -X POST \
  -d "{\"text\":\"test\",\"embedding\":${your_embedding}}" \
  -H 'Content-Type: application/json'
```

The output of the retriever microservice comprises of the a unique id for the request, initial query or the input to the retrieval microservice, a list of top
`n` retrieved documents relevant to the input query, and top_n where n refers to the number of documents to be returned.

The output is retrieved text that is relevant to the input data:
```bash
{"id":"b16024e140e78e39a60e8678622be630","retrieved_docs":[],"initial_query":"test","top_n":1,"metadata":[]}
```

### TEI Reranking Service

The TEI Reranking Service reranks the documents returned by the retrieval service. It consumes the query and list of documents and returns the document
index in decreasing order of the similarity score. The document corresponding to the index with the highest score is the most relevant document for the input query.

```bash
curl http://${host_ip}:8808/rerank \
    -X POST \
    -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
    -H 'Content-Type: application/json'
```

Sample output:
```bash
[{"index":1,"score":0.94238955},{"index":0,"score":0.120219156}]
```

### vLLM and TGI Service

In first startup, this service will take a few minutes to download the model files and perform warm up. After it's finished, the service will be ready.

::::{tab-set}

:::{tab-item} vllm
:sync: vllm

Try the command below to check whether the LLM service is ready. The output should be "Application startup complete."

```bash
docker logs vllm-service 2>&1 | grep complete
```

:::
:::{tab-item} TGI
:sync: TGI

Try the command below to check whether the LLM service is ready. The output should be "INFO text_generation_router::server: router/src/server.rs:2311: Connected"

```bash
docker logs tgi-service | grep Connected
```

:::
::::

Run the command below to use the vLLM or TGI service to generate text for the input prompt. Sample output is also shown. 
```bash
curl http://${host_ip}:9009/v1/chat/completions \
  -X POST \
  -d '{"model": "meta-llama/Meta-Llama-3-8B-Instruct", "messages": [{"role": "user", "content": "What is Deep Learning?"}], "max_tokens":17}' \
  -H 'Content-Type: application/json'
```

```bash
{"id":"chatcmpl-cc4300a173af48989cac841f54ebca09","object":"chat.completion","created":1743553002,"model":"meta-llama/Meta-Llama-3-8B-Instruct","choices":[{"index":0,"message":{"role":"assistant","content":"Deep learning is a subfield of machine learning that is inspired by the structure and function","tool_calls":[]},"logprobs":null,"finish_reason":"length","stop_reason":null}],"usage":{"prompt_tokens":15,"total_tokens":32,"completion_tokens":17,"prompt_tokens_details":null},"prompt_logprobs":null}
```

### Dataprep Microservice

The knowledge base can be updated using the dataprep microservice, which extracts text from a variety of data sources, chunks the data, embeds each chunk using the embedding microservice. Finally, the embedded vectors are stored in the Redis vector database.

`nke-10k-2023.pdf` is Nike's annual report on a form 10-K. Run this command to download the file:
```bash
wget https://github.com/opea-project/GenAIComps/blob/v1.1/comps/retrievers/redis/data/nke-10k-2023.pdf
```

Upload the file:
```bash
curl -X POST "http://${host_ip}:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F "files=@./nke-10k-2023.pdf"
```

HTTP links can also be added to the knowledge base. This command adds the opea.dev website.
```bash
curl -X POST "http://${host_ip}:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F 'link_list=["https://opea.dev"]'
```

The list of uploaded files can be retrieved using this command: 
```bash
curl -X POST "http://${host_ip}:6007/v1/dataprep/get_file" \
     -H "Content-Type: application/json"
```

To delete the file or link, use the following commands:

#### Delete link
```bash
# The dataprep service will add a .txt postfix for link file

curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "https://opea.dev.txt"}' \
     -H "Content-Type: application/json"
```

#### Delete file

```bash
curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "nke-10k-2023.pdf"}' \
     -H "Content-Type: application/json"
```

#### Delete all uploaded files and links

```bash
curl -X POST "http://${host_ip}:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "all"}' \
     -H "Content-Type: application/json"
```

### ChatQnA MegaService

```bash
curl http://${host_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "messages": "What is the revenue of Nike in 2023?"
     }'
```

Here is the output for reference:
```bash
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

## Launch UI

### Basic UI

To access the frontend, open the following URL in a web browser: http://{host_ip}:80. By default, the UI runs on port 5173 internally. A different host port can be used to access the frontend. Simply modify the port mapping in the `compose.yaml` file as shown below:
```yaml
  chatqna-xeon-ui-server:
    image: opea/chatqna-ui:${TAG:-latest}
    ...
    ports:
      - "5173:5173"
```

### (Optional) Conversational UI

To access the Conversational UI (react based) frontend, modify the UI service in the `compose.yaml` file. Replace `chatqna-xeon-ui-server` service with the `chatqna-xeon-conversation-ui-server` service as shown below:
```yaml
chaqtna-xeon-conversation-ui-server:
  image: opea/chatqna-conversation-ui:${TAG:-latest}
  container_name: chatqna-xeon-conversation-ui-server
  environment:
    - APP_BACKEND_SERVICE_ENDPOINT=${BACKEND_SERVICE_ENDPOINT}
    - APP_DATA_PREP_SERVICE_URL=${DATAPREP_SERVICE_ENDPOINT}
  ports:
    - "5174:80"
  depends_on:
    - chatqna-xeon-backend-server
  ipc: host
  restart: always
```

In addition, modify the `chatqna-xeon-nginx-server` `depends_on` field to include `chatqna-xeon-conversation-ui-server` instead of `chatqna-xeon-ui-server`.

Once the services are up, open the following URL in a web browser: http://{host_ip}:5174. By default, the UI runs on port 80 internally. A different host port can be used to access the frontend. Simply modify the port mapping in the `compose.yaml` file as shown below:
```yaml
  chatqna-xeon-conversation-ui-server:
    image: opea/chatqna-conversation-ui:${TAG:-latest}
    ...
    ports:
      - "80:80"
```

## Stop the services

To stop and remove all the containers, use the command below:
::::{tab-set}

:::{tab-item} vllm
:sync: vllm

```bash
docker compose -f compose.yaml down
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
docker compose -f compose_tgi.yaml down
```
:::
::::
