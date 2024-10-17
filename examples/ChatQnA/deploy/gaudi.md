# Single node on-prem deployment with vLLM or TGI on Gaudi AI Accelerator

This deployment section covers single-node on-prem deployment of the ChatQnA
example with OPEA comps to deploy using vLLM or TGI service. There are several
slice-n-dice ways to enable RAG with vectordb and LLM models, but here we will
be covering one option of doing it for convenience : we will be showcasing how
to build an e2e chatQnA with Redis VectorDB and neural-chat-7b-v3-3 model,
deployed on Intel® Tiber™ Developer Cloud (ITDC). To quickly learn about OPEA in just 5 minutes and set up the required hardware and software, please follow the instructions in the
[Getting Started](https://opea-project.github.io/latest/getting-started/README.html) section. If you do
not have an ITDC instance or the hardware is not supported in the ITDC yet, you can still run this on-prem.

## Overview

There are several ways to setup a ChatQnA use case. Here in this tutorial, we
will walk through how to enable the below list of microservices from OPEA
GenAIComps to deploy a single node vLLM or TGI megaservice solution.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with vLLM or TGI

The solution is aimed to show how to use Redis vectordb for RAG and
neural-chat-7b-v3-3 model on Intel Gaudi AI Accelerator. We will go through
how to setup docker container to start a microservices and megaservice . The
solution will then utilize a sample Nike dataset which is in PDF format. Users
can then ask a question about Nike and get a chat-like response by default for
up to 1024 tokens. The solution is deployed with a UI. There are 2 modes you can
use:

1. Basic UI
2. Conversational UI

Conversational UI is optional, but a feature supported in this example if you
are interested to use.

To summarize, Below is the flow of contents we will be covering in this tutorial:

1. Prerequisites
2. Prepare (Building / Pulling) Docker images
3. Use case setup
4. Deploy the use case
5. Interacting with ChatQnA deployment

## Prerequisites

First step is to clone the GenAIExamples and GenAIComps. GenAIComps are
fundamental necessary components used to build examples you find in
GenAIExamples and deploy them as microservices.

```
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
```

The examples utilize model weights from HuggingFace and langchain.

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

This step will involve building/pulling relevant docker
images with step-by-step process along with sanity check in the end. For
ChatQnA, the following docker images will be needed: embedding, retriever,
rerank, LLM and dataprep. Additionally, you will need to build docker images for
ChatQnA megaservice, and UI (conversational React UI is optional). In total,
there are 8 required and an optional docker images.

### Build/Pull Microservice images
::::{tab-set}
:::{tab-item} Pull
:sync: Pull

To pull pre-built docker images on Docker Hub, proceed to the next step. To customize 
your application, you can choose to build individual docker images for the microservices 
before proceeding.
:::
:::{tab-item} Build
:sync: Build

From within the `GenAIComps` folder, checkout the release tag.
```
cd GenAIComps
git checkout tags/v1.0
```
:::
::::

#### Build Dataprep Image

```bash
docker build --no-cache -t opea/dataprep-redis:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/dataprep/redis/langchain/Dockerfile .
```

#### Build Embedding Image

```bash
docker build --no-cache -t opea/embedding-tei:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/embeddings/tei/langchain/Dockerfile .
```

#### Build Retriever Image

```bash
docker build --no-cache -t opea/retriever-redis:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/retrievers/redis/langchain/Dockerfile .
```

#### Build Rerank Image

```bash
docker build --no-cache -t opea/reranking-tei:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/reranks/tei/Dockerfile .
```

#### Build docker

::::{tab-set}

:::{tab-item} vllm
:sync: vllm

Build vLLM docker image with hpu support
```
docker build --no-cache -t opea/llm-vllm-hpu:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/vllm/langchain/dependency/Dockerfile.intel_hpu .
```

Build vLLM Microservice image
```
docker build --no-cache -t opea/llm-vllm:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/vllm/langchain/Dockerfile .
cd ..
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
docker build --no-cache -t opea/llm-tgi:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/tgi/Dockerfile .
```
:::
::::

### Build TEI Gaudi Image

Since a TEI Gaudi Docker image hasn't been published, we'll need to build it from the [tei-gaudi](https://github.com/huggingface/tei-gaudi) repository.

```bash
git clone https://github.com/huggingface/tei-gaudi
cd tei-gaudi/
docker build --no-cache -f Dockerfile-hpu -t opea/tei-gaudi:latest .
cd ..
```

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
cd GenAIExamples
git checkout tags/v1.0
cd ChatQnA
```

```bash
docker build --no-cache -t opea/chatqna:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile .
cd ../..
```

### Build Other Service images

If you want to enable guardrails microservice in the pipeline, please use the below command instead:

```bash
cd GenAIExamples/ChatQnA/
docker build --no-cache -t opea/chatqna-guardrails:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile.guardrails .
cd ../..
```

### Build the UI Image

As mentioned, you can build 2 modes of UI

*Basic UI*

```bash
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-ui:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile .
cd ../../..
```

*Conversation UI*
If you want a conversational experience with chatqna megaservice.

```bash
cd GenAIExamples/ChatQnA/ui/
docker build --no-cache -t opea/chatqna-conversation-ui:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile.react .
cd ../../..
```

### Sanity Check
Check if you have the below set of docker images, before moving on to the next step:

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

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

:::
:::{tab-item} TGI
:sync: TGI

* opea/dataprep-redis:latest
* opea/embedding-tei:latest
* opea/retriever-redis:latest
* opea/reranking-tei:latest
* opea/tei-gaudi:latest
* opea/chatqna:latest or opea/chatqna-guardrails:latest
* opea/chatqna-ui:latest
* opea/llm-tgi:latest
:::
::::

## Use Case Setup

As mentioned the use case will use the following combination of the GenAIComps
with the tools

::::{tab-set}

:::{tab-item} vllm
:sync: vllm

|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   vLLM     |Intel/neural-chat-7b-v3-3 |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Tools and models mentioned in the table are configurable either through the
environment variable or `compose_vllm.yaml` file.
:::
:::{tab-item} TGI
:sync: TGI

|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   TGI        | Intel/neural-chat-7b-v3-3|OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Tools and models mentioned in the table are configurable either through the
environment variable or `compose.yaml` file.
:::
::::

Set the necessary environment variables to setup the use case case

```
cd GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi/
source ./set_env.sh
```

## Deploy the use case

In this tutorial, we will be deploying via docker compose with the provided
YAML file.  The docker compose instructions should be starting all the
above mentioned services as containers.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```
cd GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi
docker compose -f compose_vllm.yaml up -d
```
:::
:::{tab-item} TGI
:sync: TGI

```
cd GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi
```

Follow ONE of the methods below.
1. Use TGI for the LLM backend.

```bash
docker compose -f compose.yaml up -d
```

2. Enable the Guardrails microservice in the pipeline. It will use a TGI Guardrails service.

```bash
docker compose -f compose_guardrails.yaml up -d
```
:::
::::

### Validate microservice
#### Check Env Variables
Check the start up log by `docker compose -f ./docker/docker_compose/intel/hpu/gaudi/compose_vllm.yaml logs`.
The warning messages print out the variables if they are **NOT** set.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm
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

:::
:::{tab-item} TGI
:sync: TGI
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
:::
::::

#### Check the container status

Check if all the containers  launched via docker compose has started

For example, the ChatQnA example starts 11 docker (services), check these docker
containers are all running, i.e, all the containers  `STATUS`  are  `Up`
To do a quick sanity check, try `docker ps -a` to see if all the containers are running

::::{tab-set}

:::{tab-item} vllm
:sync: vllm
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

:::
:::{tab-item} TGI
:sync: TGI
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

Update Knowledge Base via Local File [nke-10k-2023.pdf](https://github.com/opea-project/GenAIComps/blob/main/comps/retrievers/redis/data/nke-10k-2023.pdf). Click [here](https://raw.githubusercontent.com/opea-project/GenAIComps/main/comps/retrievers/redis/data/nke-10k-2023.pdf) to download the file via any web browser or run this command to get the file on a terminal:

```bash
wget https://raw.githubusercontent.com/opea-project/GenAIComps/main/comps/retrievers/redis/data/nke-10k-2023.pdf
```

To upload the file:
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
curl ${host_ip}:8090/embed \
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
embedding service and pads other default parameters that are required for the
retrieval microservice and returns it.

```
curl http://${host_ip}:6000/v1/embeddings\
  -X POST \
  -d '{"text":"hello"}' \
  -H 'Content-Type: application/json'
```
### Retriever Microservice

To consume the retriever microservice, you need to generate a mock embedding
vector by Python script. The length of embedding vector is determined by the
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
response with default parameters required for the llm microservice.

```
curl http://${host_ip}:8000/v1/reranking \
  -X POST \
  -d '{"initial_query":"What is Deep Learning?", "retrieved_docs": [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

The input to the microservice is the `initial_query` and a list of retrieved
documents and it outputs the most relevant document to the initial query along
with other default parameter such as temperature, `repetition_penalty`,
`chat_template` and so on. We can also get top n documents by setting `top_n` as one
of the input parameters. For example:

```
curl http://${host_ip}:8000/v1/reranking \
  -X POST \
  -d '{"initial_query":"What is Deep Learning?" ,"top_n":2, "retrieved_docs": [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

Here is the output:

```
{"id":"e1eb0e44f56059fc01aa0334b1dac313","query":"Human: Answer the question based only on the following context:\n    Deep learning is...\n    Question: What is Deep Learning?","max_new_tokens":1024,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}

```
You may notice reranking microservice are with state ('ID' and other meta data),
while reranking service are not.

### vLLM and TGI Service

In first startup, this service will take more time to download the model files. 
After it's finished, the service will be ready.

Try the command below to check whether the LLM serving is ready.

```
docker logs ${CONTAINER_ID} | grep Connected
```

If the service is ready, you will get the response like below.

```
2024-09-03T02:47:53.402023Z  INFO text_generation_router::server: router/src/server.rs:2311: Connected
```

::::{tab-set}

:::{tab-item} vllm
:sync: vllm

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

vLLM service generate text for the input prompt. Here is the expected result
from vllm:

```
{"id":"cmpl-be8e1d681eb045f082a7b26d5dba42ff","object":"text_completion","created":1726269914,"model":"Intel/neural-chat-7b-v3-3","choices":[{"index":0,"text":"\n\nDeep Learning is a subset of Machine Learning that is concerned with algorithms inspired by the structure and function of the brain. It is a part of Artificial","logprobs":null,"finish_reason":"length","stop_reason":null}],"usage":{"prompt_tokens":6,"total_tokens":38,"completion_tokens":32}}d
```

**NOTE**: After launch the vLLM, it takes few minutes for vLLM server to load
LLM model and warm up.
:::
:::{tab-item} TGI
:sync: TGI

```
curl http://${host_ip}:8005/generate \
  -X POST \
  -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":64, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

TGI service generate text for the input prompt. Here is the expected result from TGI:

```
{"generated_text":"Artificial Intelligence (AI) has become a very popular buzzword in the tech industry. While the phrase conjures images of sentient robots and self-driving cars, our current AI landscape is much more subtle. In fact, it most often manifests in the forms of algorithms that help recognize the faces of"}
```

**NOTE**: After launch the TGI, it takes few minutes for TGI server to load LLM model and warm up.
:::
::::


### LLM Microservice

This service depends on the above LLM backend service startup. Give it a couple minutes to be ready on the first startup.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm
```
curl http://${host_ip}:9000/v1/chat/completions \
 -X POST \
 -d '{"query":"What is Deep Learning?","max_tokens":17,"top_p":1,"temperature":0.7,\
 "frequency_penalty":0,"presence_penalty":0, "streaming":true}' \
 -H 'Content-Type: application/json'
```
For parameters in vLLM modes, can refer to [LangChain VLLMOpenAI API](https://huggingface.co/docs/huggingface_hub/package_reference/inference_client#huggingface_hub.InferenceClient.text_generation)

:::
:::{tab-item} TGI
:sync: TGI
```
curl http://${host_ip}:9000/v1/chat/completions \
  -X POST \
  -d '{"query":"What is Deep Learning?","max_new_tokens":17,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}' \
  -H 'Content-Type: application/json'
```

For parameters in TGI modes, please refer to [HuggingFace InferenceClient API](https://huggingface.co/docs/huggingface_hub/package_reference/inference_client#huggingface_hub.InferenceClient.text_generation) (except we rename "max_new_tokens" to "max_tokens".)
:::
::::

You will get generated text from LLM:

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

#### Guardrail Microservice
If you had enabled Guardrail microservice, access via the below curl command

```
curl http://${host_ip}:9090/v1/guardrails\
  -X POST \
  -d '{"text":"How do you buy a tiger in the US?","parameters":{"max_new_tokens":32}}' \
  -H 'Content-Type: application/json'
```

## Launch UI
### Basic UI
To access the frontend, open the following URL in your browser: http://{host_ip}:5173. By default, the UI runs on port 5173 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the compose.yaml file as shown below:
```bash
  chaqna-gaudi-ui-server:
    image: opea/chatqna-ui:latest
    ...
    ports:
      - "80:5173"
```

### Conversational UI
To access the Conversational UI (react based) frontend, modify the UI service in the compose.yaml file. Replace chaqna-gaudi-ui-server service with the chatqna-gaudi-conversation-ui-server service as per the config below:
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
Once the services are up, open the following URL in your browser: http://{host_ip}:5174. By default, the UI runs on port 80 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the compose.yaml file as shown below:
```
  chaqna-gaudi-conversation-ui-server:
    image: opea/chatqna-conversation-ui:latest
    ...
    ports:
      - "80:80"
```

## Check docker container log

Check the log of container by:

`docker logs <CONTAINER ID> -t`


Check the log by  `docker logs f7a08f9867f9 -t`.

```
2024-06-05T01:30:30.695934928Z error: a value is required for '--model-id <MODEL_ID>' but none was supplied
2024-06-05T01:30:30.697123534Z
2024-06-05T01:30:30.697148330Z For more information, try '--help'.

```

The log indicates the `MODEL_ID` is not set.


::::{tab-set}

:::{tab-item} vllm
:sync: vllm

View the docker input parameters in  `./ChatQnA/docker_compose/intel/hpu/gaudi/compose_vllm.yaml`

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

:::
:::{tab-item} TGI
:sync: TGI

View the docker input parameters in  `./ChatQnA/docker_compose/intel/hpu/gaudi/compose.yaml`

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
:::
::::


The input `MODEL_ID` is  `${LLM_MODEL_ID}`

Check environment variable  `LLM_MODEL_ID`  is set correctly, spelled correctly.
Set the `LLM_MODEL_ID` then restart the containers.

Also you can check overall logs with the following command, where the
compose.yaml is the mega service docker-compose configuration file.

::::{tab-set}

:::{tab-item} vllm
:sync: vllm

```
docker compose -f ./docker_compose/intel/hpu/gaudi/compose_vllm.yaml logs
```
:::
:::{tab-item} TGI
:sync: TGI

```
docker compose -f ./docker_compose/intel/hpu/gaudi/compose.yaml logs
```
:::
::::

## Stop the services

Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:
::::{tab-set}

:::{tab-item} vllm
:sync: vllm

```
docker compose -f compose_vllm.yaml down
```
:::
:::{tab-item} TGI
:sync: TGI

```
docker compose -f compose.yaml down
```
:::
::::
