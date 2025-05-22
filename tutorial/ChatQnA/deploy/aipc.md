# Single node on-prem deployment with Ollama on AIPC

This section covers single-node on-prem deployment of the ChatQnA example using Ollama. There are several ways to enable RAG with vectordb and LLM models, but this tutorial will be covering how to build an end-to-end ChatQnA pipeline with the Redis vector database and a llama-3 model deployed on the client CPU.

## Overview

The OPEA GenAIComps microservices used to deploy a single node vLLM or TGI megaservice solution for ChatQnA are listed below:

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with Ollama

This solution is designed to demonstrate the use of Redis vectorDB for RAG and the Meta-Llama-3-8B-Instruct model for LLM inference on Intel Client PCs. The steps will involve setting up Docker containers, using a sample Nike dataset in PDF format, and posing a question about Nike to receive a response. Although multiple versions of the UI can be deployed, this tutorial will focus solely on the default version.

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

Set the `HUGGINGFACEHUB_API_TOKEN` environment variable to the value of the Hugging Face token by executing the following command:
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
export https_proxy="Your_HTTPs_Proxy"
# Example: no_proxy="localhost, 127.0.0.1, 192.168.1.1"
export no_proxy=$no_proxy,chatqna-aipc-backend-server,tei-embedding-service,retriever,tei-reranking-service,redis-vector-db,dataprep-redis-service,ollama-service
```

The examples utilize model weights from Ollama and langchain.

### Set Up Ollama LLM Service
Use [Ollama](https://ollama.com/) as the LLM service for AIPC.

Please follow the instructions to set up Ollama on the PC. This will set the entrypoint needed for the Ollama to work with the ChatQnA example.

#### Install Ollama Service

Install Ollama service with one command:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

#### Set Ollama Service Configuration

The Ollama Service Configuration file is /etc/systemd/system/ollama.service. Edit the file to set OLLAMA_HOST environment, replacing <host_ip> with the hosts IPV4 external public IP address. For example, if the host_ip is 10.132.x.y, then `Environment="OLLAMA_HOST=10.132.x.y:11434"' should be used.

```bash
Environment="OLLAMA_HOST=host_ip:11434"
```

#### Set https_proxy environment for Ollama

If the system's network is accessed through a proxy, add a https_proxy entry to the Ollama Service Configuration file:
```bash
Environment="https_proxy=Your_HTTPS_Proxy"
```

#### Restart Ollama services

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama.service
```

#### Check if the service started

```bash
netstat -tuln | grep  11434
```

The output is:

```bash
tcp        0      0 10.132.x.y:11434      0.0.0.0:*               LISTEN
```

#### Pull Ollama LLM model

Run the command to download LLM models. The <host_ip> is the one set in the `Set Ollama Service Configuration`.

```bash
export host_ip=<host_ip>
export OLLAMA_HOST=http://${host_ip}:11434
ollama pull llama3.2
```

After downloading the models, list the models by executing the `ollama list` command.

The output should be similar to the following:

```bash
NAME            ID                SIZE      MODIFIED
llama3.2:latest   a80c4f17acd5    2.0 GB    2 minutes ago
```

### Consume Ollama LLM Service

Access ollama service to verify that Ollama is functioning correctly.

```bash
curl http://${host_ip}:11434/api/generate -d '{"model": "llama3.2", "prompt":"What is Deep Learning?"}'
```

The output may look like this:

```bash
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.098813868Z","response":"Deep","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.124514468Z","response":" learning","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.149754216Z","response":" is","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.180420784Z","response":" a","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.229185873Z","response":" subset","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.263956118Z","response":" of","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.289097354Z","response":" machine","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.316838918Z","response":" learning","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.342309506Z","response":" that","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.367221264Z","response":" involves","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.39205893Z","response":" the","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.417933974Z","response":" use","done":false}
{"model":"llama3.2","created_at":"2024-10-12T12:55:28.443110388Z","response":" of","done":false}
...
```

## Use Case Setup

ChatQnA will utilize the following GenAIComps services and associated tools. The tools and models listed in the table can be configured via environment variables in either the `set_env.sh` script or the `compose.yaml` file.

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

:::
::::

Set the necessary environment variables to set up the use case. To swap out models, modify `set_env.sh` before running it. For example, the environment variable `LLM_MODEL_ID` can be changed to another model by specifying the HuggingFace model card ID. 

```bash
cd $WORKSPACE/GenAIExamples/ChatQnA/docker_compose/intel/cpu/aipc
source ./set_env.sh
```

## Deploy the Use Case

Run `docker compose` with the provided YAML file to start all the services mentioned above as containers.

::::{tab-set}
:::{tab-item} Ollama
:sync: Ollama

```bash
docker compose -f compose.yaml up -d
```
:::
::::

### Check Env Variables
After running `docker compose`, check for warning messages for environment variables that are **NOT** set. Address them if needed. 

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

### Check the container status

Check if all the containers launched via `docker compose` are running i.e. each container's `STATUS` is `Up` and `Healthy`.

Run this command to see this info:
```bash
docker ps -a
```

Sample output:
::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama

```bash
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

Each docker container's log can also be checked using:

```bash
docker logs <CONTAINER_ID OR CONTAINER_NAME>
```

## Validate Microservices

This section will guide through the various methods for interacting with the deployed microservices.

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

### Ollama Service

Run the command below to use Ollama to generate text for the input prompt.
```bash
curl http://${host_ip}:11434/api/generate -d '{"model": "llama3", "prompt":"What is Deep Learning?"}'
```

Ollama service generates text for the input prompt. Here is the expected result from Ollama:
```bash
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
```

### Dataprep Microservice

The knowledge base can be updated using the dataprep microservice, which extracts text from a variety of data sources, chunks the data, and embeds each chunk using the embedding microservice. Finally, the embedded vectors are stored in the Redis vector database.

`nke-10k-2023.pdf` is Nike's annual report on a form 10-K. Run this command to download the file:
```bash
wget https://github.com/opea-project/GenAIComps/blob/main/comps/third_parties/pathway/src/data/nke-10k-2023.pdf
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
     "model":  "'"${OLLAMA_MODEL}"'",
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

This will ensure the NGINX service is working properly.
```bash
curl http://${host_ip}:${NGINX_PORT}/v1/chatqna \
    -H "Content-Type: application/json" \
    -d '{"messages": "What is the revenue of Nike in 2023?"}'
```

The output will be similar to that of the ChatQnA megaservice.

## Launch UI

To access the frontend, open the following URL in a web browser: http://${host_ip}:${NGINX_PORT}. By default, the UI runs on port 5173 internally. A different host port can be used to access the frontend by modifying the port mapping in the `compose.yaml` file as shown below:
```yaml
  chatqna-aipc-ui-server:
    image: opea/chatqna-ui${TAG:-latest}
    ...
    ports:
      - "YOUR_HOST_PORT:5173" # Change YOUR_HOST_PORT to the desired port
```

After making this change, rebuild and restart the containers for the change to take effect. 

### Stop the Services

Navigate to the `docker compose` directory for this hardware platform.
```bash
cd $WORKSPACE/GenAIExamples/ChatQnA/docker_compose/intel/cpu/aipc
```

To stop and remove all the containers, use the command below:

::::{tab-set}

:::{tab-item} Ollama
:sync: Ollama
To stop and remove all the containers, use the command below:
```bash
docker compose -f compose.yaml down
```

:::
::::
