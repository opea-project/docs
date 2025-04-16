# Single node on-prem deployment with TGI on Nvidia gpu

This deployment section covers single-node on-prem deployment of the ChatQnA example using the TGI LLM service. There are several ways to enable RAG with vectordb and LLM models, but this tutorial will be covering how to build an end-to-end ChatQnA pipeline with the Redis vector database and meta-llama/Meta-Llama-3-8B-Instruct model deployed on NVIDIA GPUs.

## Overview

The list of microservices from OPEA GenAIComps are used to deploy a single node vLLM or TGI megaservice solution for ChatQnA.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with TGI

The solution is aimed to show how to use Redis vectorDB for RAG and Meta-Llama-3-8B-Instruct model for LLM inference on NVIDIA GPUs. Steps will include setting up docker containers, utilizing a sample Nike dataset in PDF format, and asking a question about Nike to get a response. There are multiple versions of the UI that can be deployed but only the default one will be covered in this tutorial.

## Prerequisites

Set up a workspace and clone the [GenAIExamples](https://github.com/opea-project/GenAIExamples) GitHub repo.
```bash
export WORKSPACE=<Path>
cd $WORKSPACE
git clone https://github.com/opea-project/GenAIExamples.git # GenAIExamples
```

**(Optional)** It is recommended to use a stable release version by setting `RELEASE_VERSION` to a **number only** (i.e. 1.0, 1.1, etc) and checkout that version using the tag. Otherwise, by default, the main branch with the latest updates will be used.
```bash
export RELEASE_VERSION=<Release_Version> # Set desired release version - number only
cd GenAIExamples
git checkout tags/v${RELEASE_VERSION}
cd ..
```

Set up a [HuggingFace](https://huggingface.co/) account and generate a [user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token). Request access to the [meta-llama/Meta-Llama-3-8B-Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct) model.

Set an environment variable with the HuggingFace token:
```bash
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

The example requires setting the `host_ip` to "localhost" to deploy the microservices on endpoints enabled with ports.
```bash
export host_ip="localhost"
```

Set the NGINX port.
```bash
# Example: NGINX_PORT=80
export NGINX_PORT=<Nginx_Port>
```

For machines behind a firewall, set up the proxy environment variables:
```bash
export http_proxy="Your_HTTP_Proxy"
export https_proxy="Your_HTTPs_Proxy"
# Example: no_proxy="localhost, 127.0.0.1, 192.168.1.1"
export no_proxy="Your_No_Proxy",chatqna-ui-server,chatqna-backend-server,dataprep-redis-service,tei-embedding-service,retriever,tei-reranking-service,tgi-service
```

## Use Case Setup

ChatQnA will use the following GenAIComps and corresponding tools. Tools and models mentioned in the table are configurable either through environment variables in the `set_env.sh` or `compose.yaml` file.

::::{tab-set}

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
cd $WORKSPACE/GenAIExamples/ChatQnA/docker_compose/nvidia/gpu
source ./set_env.sh
```

## Deploy the Use Case

Run `docker compose` with the provided YAML file to start all the services mentioned above as containers.

::::{tab-set}
:::{tab-item} TGI
:sync: TGI

```bash
docker compose -f compose.yaml up -d
```
:::
::::

### Check Env Variables
After running `docker compose`, check for warning messages for environment variables that are **NOT** set. Address them if needed.

::::{tab-set}
:::{tab-item} TGI
:sync: TGI

    ubuntu@nvidia-vm:~/GenAIExamples/ChatQnA/docker_compose/nvidia/gpu$ docker compose -f ./compose.yaml up -d
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_API_KEY" variable is not set. Defaulting to a blank string.
    WARN[0000] The "LANGCHAIN_TRACING_V2" variable is not set. Defaulting to a blank string.
    WARN[0000] /home/ubuntu/GenAIExamples/ChatQnA/docker_compose/nvidia/gpu/compose.yaml: `version` is obsolete
:::
::::

### Check Container Statuses

Check if all the containers launched via `docker compose` are running i.e. each container's `STATUS` is `Up` and `Healthy`.

Run this command to see this info:
```bash
docker ps -a
```

Sample output:
::::{tab-set}
:::{tab-item} TGI
:sync: TGI

```bash
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED        STATUS        PORTS                                                                                  NAMES
3b5fa9a722da   opea/chatqna-ui:latest                                  "docker-entrypoint.s…"   32 hours ago   Up 2 hours   0.0.0.0:5173->5173/tcp, :::5173->5173/tcp                                              chatqna-ui-server
d3b37f3d1faa   opea/chatqna:latest                                     "python chatqna.py"      32 hours ago   Up 2 hours   0.0.0.0:8888->8888/tcp, :::8888->8888/tcp                                              chatqna-backend-server
b3e1388fa2ca   opea/reranking-tei:latest                               "python reranking_te…"   32 hours ago   Up 2 hours   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp                                              reranking-tei-server
24a240f8ad1c   opea/retriever-redis:latest                             "python retriever_re…"   32 hours ago   Up 2 hours   0.0.0.0:7000->7000/tcp, :::7000->7000/tcp                                              retriever-redis-server
9c0d2a2553e8   opea/embedding-tei:latest                               "python embedding_te…"   32 hours ago   Up 2 hours   0.0.0.0:6000->6000/tcp, :::6000->6000/tcp                                              embedding-tei-server
24cae0db1a70   opea/llm-tgi:latest                                    "bash entrypoint.sh"     32 hours ago   Up 2 hours   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp                                              llm-tgi-server
ea3986c3cf82   opea/dataprep-redis:latest                              "python prepare_doc_…"   32 hours ago   Up 2 hours   0.0.0.0:6007->6007/tcp, :::6007->6007/tcp                                              dataprep-redis-server
e10dd14497a8   redis/redis-stack:7.2.0-v9                              "/entrypoint.sh"         32 hours ago   Up 2 hours   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp   redis-vector-db
79276cf45a47   ghcr.io/huggingface/text-embeddings-inference:cpu-1.2   "text-embeddings-rou…"   32 hours ago   Up 2 hours   0.0.0.0:8090->80/tcp, :::8090->80/tcp                                                  tei-embedding-server
4943e5f6cd80   ghcr.io/huggingface/text-embeddings-inference:cpu-1.2   "text-embeddings-rou…"   32 hours ago   Up 2 hours   0.0.0.0:8808->80/tcp, :::8808->80/tcp                                                  tei-reranking-server
```
:::
::::

Each docker container's log can also be checked using:

```bash
docker logs <CONTAINER_ID OR CONTAINER_NAME>
```

## Validate Microservices

This section will walk through the different ways to interact with the microservices deployed.

### TEI Embedding Service

The TEI embedding service takes in a string as input, embeds the string into a vector of a specific length determined by the embedding model, and returns this vector.

```bash
curl ${host_ip}:8090/embed \
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

The output of the retriever microservice comprises of the a unique id for the request, initial query or the input to the retrieval microservice, a list of top `n` retrieved documents relevant to the input query, and top_n where n refers to the number of documents to be returned.

The output is retrieved text that is relevant to the input data:
```bash
{"id":"b16024e140e78e39a60e8678622be630","retrieved_docs":[],"initial_query":"test","top_n":1,"metadata":[]}
```

### TEI Reranking Service

The TEI Reranking Service reranks the documents returned by the retrieval service. It consumes the query and list of documents and returns the document index in decreasing order of the similarity score. The document corresponding to the index with the highest score is the most relevant document for the input query.

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

### TGI Service

In first startup, this service will take a few minutes to download the model files and perform warm up. After it's finished, the service will be ready.

::::{tab-set}

:::{tab-item} TGI
:sync: TGI

Try the command below to check whether the LLM service is ready. The output should be "INFO text_generation_router::server: router/src/server.rs:2311: Connected"
```bash
docker logs tgi-service | grep Connected
```

Run the command below to use the TGI service to generate text for the input prompt. Sample output is also shown. 
```bash
curl http://${host_ip}:8008/generate \
  -X POST \
  -d '{"inputs":"What is Deep Learning?", \
     "parameters":{"max_new_tokens":17, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

```bash
{"id":"chatcmpl-cc4300a173af48989cac841f54ebca09","object":"chat.completion","created":1743553002,"model":"meta-llama/Meta-Llama-3-8B-Instruct","choices":[{"index":0,"message":{"role":"assistant","content":"Deep learning is a subfield of machine learning that is inspired by the structure and function","tool_calls":[]},"logprobs":null,"finish_reason":"length","stop_reason":null}],"usage":{"prompt_tokens":15,"total_tokens":32,"completion_tokens":17,"prompt_tokens_details":null},"prompt_logprobs":null}
```

:::
::::

### ChatQnA MegaService

This will ensure the megaservice is working properly. 
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

### NGINX Service

This will ensure the NGINX ervice is working properly.
```bash
curl http://${host_ip}:${NGINX_PORT}/v1/chatqna \
    -H "Content-Type: application/json" \
    -d '{"messages": "What is the revenue of Nike in 2023?"}'
```

The output will be similar to that of the ChatQnA megaservice.

## Launch UI

### Basic UI

To access the frontend, open the following URL in your browser: http://${host_ip}:${NGINX_PORT}. By default, the UI runs on port 5173 internally. If you prefer to use a different to access the frontend by modifying the port mapping in the `compose.yaml` file as shown below:
```yaml
  chatqna-ui-server:
    image: opea/chatqna-ui:${TAG:-latest}
    ...
    ports:
      - "YOUR_HOST_PORT:5173" # Change YOUR_HOST_PORT to the desired port
```

After making this change, rebuild and restart the containers for the change to take effect. 

### Stop the Services

Navigate to the `docker compose` directory for this hardware platform.
```bash
cd $WORKSPACE/GenAIExamples/ChatQnA/docker_compose/nvidia/gpu
```

To stop and remove all the containers, use the command below:
::::{tab-set}
:::{tab-item} TGI
:sync: TGI

```bash
docker compose -f compose.yaml down
```
:::
::::
