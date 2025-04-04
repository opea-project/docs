# Single node on-prem deployment with TGI on Xeon Scalable processors

This deployment section covers single-node on-prem deployment of the DocIndexRetriever example with OPEA comps to deploy using TGI service. The solution demonstrates building a doc retriever service using the TGI deployed on Intel® Xeon® Scalable processors. To quickly learn about OPEA in just 5 minutes and set up the required hardware and software, please follow the instructions in the [Getting Started](../../../getting-started/README.md) section.

## Overview

There are several ways to setup a DocIndexRetriever use case. Here in this tutorial, we will walk through how to enable the below list of microservices from OPEA GenAIComps to deploy a single node TGI megaservice solution.

1. Embedding TEI Service
2. Retriever Vector Store Service 
3. Rerank TEI Service
4. Dataprep Service

The solution is aimed to show how to use all components of DocIndexRetriever on Intel Xeon Scalable processors. We will go through how to setup docker container to start a microservices and megaservice.

## Prerequisites

The first step is to clone the GenAIExamples and GenAIComps projects. GenAIComps are fundamental necessary components used to build the examples you find in GenAIExamples and deploy them as microservices. Set an environment variable for the desired release version with the number only (i.e. 1.0, 1.1, etc) and checkout using the tag with that version.

```bash
# Set workspace
export WORKSPACE=<path>
cd $WORKSPACE

# Set desired release version - number only
export RELEASE_VERSION=<insert-release-version>

# GenAIComps
git clone https://github.com/opea-project/GenAIComps.git
cd GenAIComps
git checkout tags/v${RELEASE_VERSION}
cd ..

# GenAIExamples
git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples
git checkout tags/v${RELEASE_VERSION}
cd ..
```

The example requires you to set the the following variables to deploy the microservices on
endpoint enabled with ports.

```bash
export host_ip=$(hostname -I | awk '{print $1}')
export HUGGINGFACEHUB_API_TOKEN=<your HF token>
export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
export RERANK_MODEL_ID="BAAI/bge-reranker-base"
export TEI_EMBEDDING_ENDPOINT="http://${host_ip}:6006"
export TEI_RERANKING_ENDPOINT="http://${host_ip}:8808"
export EMBEDDING_SERVICE_HOST_IP=${host_ip}
export RETRIEVER_SERVICE_HOST_IP=${host_ip}
export RERANK_SERVICE_HOST_IP=${host_ip}
export LLM_SERVICE_HOST_IP=${host_ip}
export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8000/v1/retrievaltool"
export DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/ingest"
```

Make sure to setup Proxies if you are behind a firewall
```bash
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Prepare (Building / Pulling) Docker images

This step involves either building or pulling four required Docker images. Each image serves a specific purpose in the DocIndexRetriever architecture.

::::::{tab-set}

:::::{tab-item} Pull
:sync: Pull

If you decide to pull the docker containers and not build them locally, you can proceed to the next step where all the necessary containers will be pulled in from Docker Hub.

:::::
:::::{tab-item} Build
:sync: Build

Follow the steps below to build the docker images from within the `GenAIComps` folder.
**Note:** For RELEASE_VERSIONS older than 1.0, you will need to add a 'v' in front 
of ${RELEASE_VERSION} to reference the correct image on Docker Hub.

```bash
cd $WORKSPACE/GenAIComps
```

### Build Embedding TEI Image

Build the Embedding TEI service image:

```bash
docker build -t opea/embedding:${RELEASE_VERSION} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/embeddings/src/Dockerfile .
```

### Build Retriever Vector Store Image

Build the Retriever Vector Store service image:

```bash
docker build -t opea/retriever:${RELEASE_VERSION} --build-arg
https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/retrievers/src/Dockerfile .
```

### Build Rerank TEI Image

Build the Rerank TEI service image:

```bash
docker build -t opea/reranking:${RELEASE_VERSION} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/reranking/src/Dockerfile .
```

### Build Dataprep Image

Build the Dataprep service image:

```bash
docker build -t opea/dataprep:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/dataprep/src/Dockerfile .
```

### Build MegaService Image

The Megaservice is a pipeline that channels data through different microservices, each performing varied tasks. We define the different microservices and the flow of data between them in the `retrieval_tool.py` file.

Build the megaservice image for this use case.

```bash
cd $WORKSPACE/GenAIExamples/DocIndexRetriever/
docker build --no-cache -t opea/doc-index-retriever:${RELEASE_VERSION} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./Dockerfile .
```

### Sanity Check

Before proceeding, verify that you have all required Docker images by running `docker images`. You should see the following images:

* opea/embedding:${RELEASE_VERSION}
* opea/retriever:${RELEASE_VERSION}
* opea/reranking:${RELEASE_VERSION}
* opea/dataprep:${RELEASE_VERSION}
* opea/doc-index-retriever:${RELEASE_VERSION}

:::::
::::::

## Use Case Setup

The use case will use the following combination of the GenAIComps with the tools.

|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       | OPEA Microservice |
|VectorDB             |  Redis       | NA                       | Open source service |
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    | OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |

Tools and models mentioned in the table are configurable either through the environment variable or `compose.yaml`

Set the necessary environment variables to setup the use case by running the `set_env.sh` script.

Run the `set_env.sh` script.
```bash
cd $WORKSPACE/GenAIExamples/DocIndexRetriever/docker_compose/intel/cpu/xeon
source ./set_env.sh
```

## Deploy the use case

In this tutorial, we will be deploying via docker compose with the provided YAML file. The docker compose instructions should start all the above-mentioned services as containers.

```bash
cd $WORKSPACE/GenAIExamples/DocIndexRetriever/docker_compose/intel/cpu/xeon/
docker compose up -d

# DocRetriever without Rerank (optional)
docker compose -f compose_without_rank.yaml up -d
```

Note: add the following environment variables in compose yaml if meet issues for downloading models:
```bash
HF_ENDPOINT: https://hf-mirror.com
HF_HUB_ENABLE_HF_TRANSFER: false
```

### Validate microservice

#### Check Env Variables

Check the startup log by `docker compose -f ./compose.yaml logs`.
The warning messages print out the variables if they are **NOT** set.

```bash
GenAIExamples/DocIndexRetriever/docker_compose/intel/cpu/xeon$ sudo -E docker compose -f ./compose.yaml logs
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string.
```

#### Check the container status

Check if all the containers launched via docker compose have started.
For example, the AudioQnA example starts 5 docker containers (services), check these docker containers are all running, i.e., all the containers `STATUS` are `Up`.

To do a quick sanity check, try `docker ps -a` to see if all the containers are running.

```bash
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED        STATUS        PORTS                                                                                  NAMES
3b5fa9a722da   opea/doc-index-retriever-server:${RELEASE_VERSION}                                  "docker-entrypoint.s…"   32 hours ago   Up 2 hours   0.0.0.0:8889->8889/tcp, :::8889->8889/tcp                                              doc-index-retriever-server
b3e1388fa2ca   opea/reranking-tei:${RELEASE_VERSION}                               "python reranking_te…"   32 hours ago   Up 2 hours   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp                                              reranking-tei-xeon-server
24a240f8ad1c   opea/retriever-redis:${RELEASE_VERSION}                             "python retriever_re…"   32 hours ago   Up 2 hours   0.0.0.0:7000->7000/tcp, :::7000->7000/tcp                                              retriever-redis-server
9c0d2a2553e8   opea/embedding-tei:${RELEASE_VERSION}                               "python embedding_te…"   32 hours ago   Up 2 hours   0.0.0.0:6000->6000/tcp, :::6000->6000/tcp                                              embedding-tei-server
ea3986c3cf82   opea/dataprep-redis:${RELEASE_VERSION}                              "python prepare_doc_…"   32 hours ago   Up 2 hours   0.0.0.0:6007->6007/tcp, :::6007->6007/tcp                                              dataprep-redis-server
e10dd14497a8   redis/redis-stack:7.2.0-v9                              "/entrypoint.sh"         32 hours ago   Up 2 hours   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp   redis-vector-db
79276cf45a47   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "text-embeddings-rou…"   32 hours ago   Up 2 hours   0.0.0.0:6006->80/tcp, :::6006->80/tcp                                                  tei-embedding-server
4943e5f6cd80   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "text-embeddings-rou…"   32 hours ago   Up 2 hours   0.0.0.0:8808->80/tcp, :::8808->80/tcp                                                  tei-reranking-server
```

## Interacting with DocIndexRetriever deployment

In this section, you will walk through the different ways to interact with the deployed microservices.

### Add Knowledge Base via HTTP Links

```bash
curl -X POST "http://${host_ip}:6007/v1/dataprep/ingest" \
     -H "Content-Type: multipart/form-data" \
     -F 'link_list=["https://opea.dev"]'
# expected output
{"status":200,"message":"Data preparation succeeded"}
```

### Retrieval from KnowledgeBase

```bash
curl http://${host_ip}:8889/v1/retrievaltool -X POST -H "Content-Type: application/json" -d '{
     "messages": "Explain the OPEA project?"
     }'

# expected output
{"id":"354e62c703caac8c547b3061433ec5e8","reranked_docs":[{"id":"06d5a5cefc06cf9a9e0b5fa74a9f233c","text":"Close SearchsearchMenu WikiNewsCommunity Daysx-twitter linkedin github searchStreamlining implementation of enterprise-grade Generative AIEfficiently integrate secure, performant, and cost-effective Generative AI workflows into business value.TODAYOPEA..."}],"initial_query":"Explain the OPEA project?"}
```

## Check the docker container logs

Following is an example of debugging using Docker logs:

Check the log of the container using:

`docker logs <CONTAINER ID> -t`

View the docker input parameters in $WORKSPACE/GenAIExamples/DocIndexRetriever/docker_compose/intel/cpu/xeon/compose.yaml

### Stop the services

Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:

```bash
docker compose -f compose.yaml down
```