# Customize with new VectorDB

Adding a new VectorDB to OPEA involves minimal changes to OPEA sub-project [GenAIComps](https://github.com/opea-project/GenAIComps) that covers installation, launch, usage, and tests. 

The changes are distributed in 3 components:

## Third_parties
The new VectorDB should be setup in opea-project/GenAIComps/comps/third_parties. 

It will have the below file structure under the new VectorDB folder.

    ```
    third-parties
    |__<Vector_DB>
       |__deployment
       |  |__docker_compose
       |     |__compose.yaml
       |     |__<Vector_DB>.yaml
       |__src
          |__ __init__.py
          |__README.md
    ```

    compose.yaml details the required configuration for the VectorDB

    <Vector_DB>.yaml details corresponding parameters for VectorDB 

    README.md details the setup to bring the server up.

    This third-party Vector database setup should be described in README.md file under:
    GenAIComps/comps/third_parties/<Vector_ DB>/src 
    
    Following is the outline of README.md 

    Make sure the Vector database setup is complete, and you can start the database server on a port.

## Dataprep
Customized dataprep microservice for <Vector_DB> in opea-project/GenAIComps/comps/dataprep.

It will have the below file structure under the dataprep folder.

    ```
    dataprep
    |__deployment
    |  |__docker_compose
    |  |  |__compose.yaml
    |  |__kubernetes
    |     |__<Vector_DB>.yaml
    |     |__README.md
    |__src
    |__integrations
    |  |__<Vector_DB>.py
    |__README_<Vector_DB>.md
    ```

    compose.yaml details the required configuration for the VectorDB

    <Vector_DB>.yaml add Vector_DB parameters for K8

    README.md adds details to enable VectorDB on Kubernetes cluster

    <Vector_DB>.py should inherit the below classes and provide definition for the methods
    ```
    OpeaDataprepLoader
        invoke() 
        ingest_files() 
        get_files() 
        delete_files() 
    OpeaDataprepMultiModalLoader 
        invoke() 
        ingest_files() 
        ingest_videos() 
        ingest_generate_transcripts() 
        ingest_generate_captions() 
        get_files() 
        get_one_file() 
        get_videos() 
        delete_files()
    ```
    README_<Vector_DB>.md details the steps to start the dataprep microservice with the VectorDB
    along with validation.

    Following is the outline of README_<Vector_DB>.md 

### Dataprep Microservice with <Vector_DB>

####	Start the <Vector_DB> server

        This will be detailed in GenAIComps/comps/third_parties/<Vector_DB>/src/README.md
        Provide link here.

####	 Build Docker Image
        
        cd GenAIComps/
        build dataprep <Vector_DB> docker image
        docker build -t opea/dataprep:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy --build-arg no_proxy=$no_proxy -f comps/dataprep/src/Dockerfile .
        
####	Setup Environment Variables

        export <Vector_DB>_HOST=${your_<Vector_DB>_host_ip}
        export <Vector_DB>_PORT=${your_<Vector_DB>_port}

#### Start TEI Embedding server

        Start the TEI server on a port($your_port) and setup environment variable.
        export TEI_EMBEDDING_ENDPOINT="http://localhost:$your_port"

#### Run Docker with CLI or Docker Compose Using port 6007 for Dataprep Microservice
    
##### Run Docker with CLI (Option A)
            
        docker run -d --name="dataprep-<Vector_DB>-server" -p 6007:6007 --ipc=host -e http_proxy=$http_proxy -e  https_proxy=$https_proxy -e no_proxy=$no_proxy -e TEI_EMBEDDING_ENDPOINT=${TEI_EMBEDDING_ENDPOINT} -e <Vector_DB>_HOST=$<Vector_DB>_HOST -e HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN} -e  DATAPREP_COMPONENT_NAME="OPEA_DATAPREP_<Vector_DB>" opea/dataprep:latest
        
#####	Run with Docker Compose (Option B)
        
        cd comps/dataprep/deployment/docker_compose
        docker compose -f compose_<Vector_DB>.yaml up -d
        

### Validate Dataprep Microservice

    Once document preparation microservice for <Vector_DB>; is started, user can use below command to invoke the microservice which converts the document to embedding and save to the database.

        curl -X POST -H "Content-Type: application/json" -d '{"path":"/path/to/document"}' http://localhost:6007/v1/dataprep/ingest

## Retrievers
Customized Retriever microservice for <Vector_DB> in opea-project/GenAIComps/comps/retrievers.

It will have the below file structure under the retrievers folder

    ```
    retrievers
    |__deployment
    |  |__docker_compose
    |  |  |__compose.yaml
    |  |__kubernetes
    |     |__<Vector_DB>-values.yaml
    |     |__README.md
    |__src
    |__integrations
    |  |__config.py
    |  |__<Vector_DB>.py
    |__README_<Vector_DB>.md
    ```
    compose.yaml - Add retriever configuration specific to <Vector_DB>

    <Vector_DB>-values.yaml adds VectorDB parameters for K8

    README.md adds details to enable VectorDB on Kubernetes cluster

    config.py adds VectorDB specific environment variables

    <Vector_DB>.py registers the VectorDB retriever component and provides definition for
    ```
        __initialize_embedder() 
        __initialize_client() 
        check_health() 
        invoke()
    ```
    README_<Vector_DB>.md details the steps to start the retriever microservice with the VectorDB along with validation.

    Following is the outline of README_<Vector_DB>.md 

### Retriever Microservice with <Vector_DB>

####	Start the <Vector_DB> server 

        This will be detailed in GenAIComps/comps/third_parties/<Vector_DB>/src/README.md
        Provide link here.
   
####	Build Docker Image

        cd GenAIComps/
        docker build -t opea/retriever:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/retrievers/src/Dockerfile .

####	Setup Environment Variables

        export <Vector_DB>_HOST=${your_<Vector_DB>_host_ip}
        export <Vector_DB>_PORT=${your_<Vector_DB>_port}

####	Start TEI Embedding server

        Start the TEI server on a port($your_port) and setup environment variable
        export TEI_EMBEDDING_ENDPOINT="http://localhost:$your_port"

####	Run Docker with CLI or Docker Compose Using port 7000 for Retriever Microservice

#####	Run Docker with CLI (Option A)

        docker run -d --name="retriever-<Vector_DB>-server" -p 7000:7000 --ipc=host -e http_proxy=$http_proxy -e  https_proxy=$https_proxy -e no_proxy=$no_proxy -e TEI_EMBEDDING_ENDPOINT=${your_embedding_endpoint}  
        -e MILVUS_HOST=${your_milvus_host_ip} -e HUGGINGFACEHUB_API_TOKEN=${your_hf_api_token} -e RETRIEVER_COMPONENT_NAME=$RETRIEVER_COMPONENT_NAME opea/retriever:latest

#####	Run Docker with Docker Compose (Option B)

        cd ../deployment/docker_compose
        export service_name="retriever-<Vector_DB>"
        docker compose -f compose.yaml up ${service_name} -d


### Validate Retriever Microservice

#### Check Service Status

        curl http://localhost:7000/v1/health_check \
        -X GET \
        -H 'Content-Type: application/json'

    Make sure there is data in the Vector_DB. You could verify data is stored in Vector_DB using dataprep microservice. Example is ingesting Nike_2023 Revenue file. (Note: We need to add link to the file).

#### Validation

        curl http://${your_ip}:7000/v1/retrieval \
        -X POST \
        -d "{\"text\":\"What is the revenue of Nike in 2023?\",\"embedding\":${your_embedding}}" \
        -H 'Content-Type: application/json'

# Customize the VectorDB for the ChatQnA Example

The OPEA sub-project [GenAIExamples](https://github.com/opea-project/GenAIExamples) houses multiple GenAI RAG sample applications such as chatbots, document summarization, code generation, and code translation to name a few. The [ChatQnA application](https://github.com/opea-project/GenAIExamples/tree/main/ChatQnA) is the primary example and contains instructions to deploy on a variety of hardware (such as Intel CPUs and Gaudi accelerator and AMD’s ROCm), in environments such as Docker and Kubernetes, including how to customize an application pipeline using different vector database backends.

## Add new VectorDB to ChatQnA Example

This deployment section covers how to add a new Vector DB to ChatQnA example with OPEA comps. Here we will be showcasing  how to build an (end-to-end) e2e ChatQnA with a new VectorDB.

### Overview

There are several ways to setup a ChatQnA use case with different VectorDBs. Here in this tutorial, we will walk through how to enable a new VectorDB with the below list of microservices from OPEA:
GenAIComps to setup a ChatQnA.
```
1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with Ollama
```
To add a new VectorDB to OPEA involves minimal changes to OPEA sub-project [GenAIComps](https://github.com/opea-project/GenAIComps) that covers installation, launch, usage, and tests. The necessary customizations are covered in detail [here]

### Prerequisites 

We start by cloning the GenAIExamples and GenAIComps projects. GenAIComps is the fundamental and necessary component used to build the examples examples you find in GenAIExamples and deploy them as microservices. Next, set an environment variable for the desired release version with the **number only** (i.e. 1.0, 1.1, etc) and checkout using the tag with that version. The GenAIComps should contain the customized components(third_party, dataprep, retrievers) for the VectorDB as mentioned before.

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

To customize ChatQnA with the new VectorDB the changes are in GenAIExamples/ChatQnA
```
ChatQnA
|__docker_compose
   |__intel
      |__cpu/xeon
      |  |__compose_<Vector_DB>.yaml
      |  |__<Vector_DB>.yaml
      |  |__README_<Vector_DB>.md
      |__hpu/gaudi
         |__compose_<Vector_DB>.yaml
         |__README_<Vector_DB>.md
```
VectorDB.yaml adds the VectorDB specific configurations

compose_<Vector_DB>.yaml contains all the necessary configs to launch a ChatQnA pipeline with the VectorDB.
The different microservices are configured in different sections
```
    services: VectorDB specific services and healthcheck

    dataprep-<Vector_DB>-service: this references opea-project/GenAIComps/comps/dataprep/ opea-project/GenAIComps/comps/dataprep/deployment/docker_compose/compose.yaml 

    retriever-<Vector_DB>-service: this references opea-project/GenAIComps/comps/retrievers/deployment/docker_compose/compose.yaml

    tei-embedding-service: references TEI component

    tei-reranking-service: references ReRanking component

    vllm-service: the inference Serving service

    chatqna-xeon-backend-server: For Xeon only

    chatqna-xeon-ui-server: for Xeon only

    chatqna-xeon-nginx-server: Load balancer for Xeon only

    chatqna-gaudi-backend-server: for Gaudi only

    chatqna-gaudi-ui-server: for Gaudi only

    chatqna-gaudi-nginx-server:Load balancer for Gaudi only
```
README_<Vector_DB>.md adds details to start the Mega service of ChatQnA on Xeon in respective folders

README_<Vector_DB>.md adds details to start the Mega service of ChatQnA on Gaudi in respective folders.

Following are the contents of README_<Vector_DB>.md 

### Build Mega Service of ChatQnA (with VectorDB)

This document outlines the deployment process for a ChatQnA application utilizing the [GenAIComps](https://github.com/opea-project/GenAIComps.git) microservice pipeline on Intel Xeon server. The steps include Docker image creation, container deployment via Docker Compose, and service execution to integrate microservices such as `embedding`, `retriever`, `rerank`, and `llm`.

Quick Start:

        1. Set up the environment variables.
        2. Run Docker Compose.
        3. Consume the ChatQnA Service.

The default pipeline deploys with vLLM as the LLM serving component and leverages the re-rank component. 

Note: The default LLM is `meta-llama/Meta-Llama-38B-Instruct`. Before deploying the aplication, please make sure either you've requested and have been granted access to it on [HuggingFace](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct) or you've downloaded the model locally from [ModelScope](https://www.modelscope.cn/models).

#### Quick Start: 1. Setup Environment Variable

To set up environment variables for deploying ChatQnA services, follow these steps:

##### Set the required environment variables:

   ```bash
   # Example: host_ip="192.168.1.1"
   export host_ip="External_Public_IP"
   export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
   ```

##### If you are in a proxy environment, also set the proxy-related environment variables:
   ```bash
   export http_proxy="Your_HTTP_Proxy"
   export https_proxy="Your_HTTPs_Proxy"
   # Example: no_proxy="localhost, 127.0.0.1, 192.168.1.1"
   export no_proxy="Your_No_Proxy",chatqna-xeon-ui-server,chatqna-xeon-backend-server,dataprep-pinecone-service,tei-embedding-service,retriever,tei-reranking-service,tgi-service,vllm-service
   ```

##### Set up other environment variables, make sure to update the INDEX_NAME variable to Pinecone index value:
   ```bash
   source ./set_env.sh
   ```

#### Quick Start: 2.Run Docker Compose
```bash
docker compose -f compose_<Vector_DB>.yaml up -d
```
It will automatically download the docker image on `docker hub`:

```bash
docker pull opea/chatqna:latest
docker pull opea/chatqna-ui:latest
```

Note: You should build docker image from source by yourself if:
- You are developing off the git main branch (as the container's ports in the repo may be different from the published docker image).
- You can't download the docker image.
- You want to use a specific version of Docker image.

#### QuickStart: 3.Consume the ChatQnA Service
```bash
curl http://${host_ip}:8888/v1/chatqna \
    -H "Content-Type: application/json" \
    -d '{
        "messages": "What is the revenue of Nike in 2023?"
    }'
```
### Build Docker Images

First of all, you need to build Docker Images locally and install the python package of it.
```bash
git clone https://github.com/opea-project/GenAIComps.git
cd GenAIComps
```

#### Build Retriever Image
```bash
docker build --no-cache -t opea/retriever:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/retrievers/src/Dockerfile .
```

#### Build Dataprep Image
```bash
docker build --no-cache -t opea/dataprep:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/dataprep/src/Dockerfile .
cd ..
```

#### Build MegaService Docker Image
Option 1. MegaService with Rerank
    To construct the Mega Service with Rerank, we utilize the [GenAIComps](https://github.com/opea-project/GenAIComps.git) microservice pipeline within the `chatqna.py` Python script. Build MegaService Docker image via below command:

    ```bash
    git clone https://github.com/opea-project/GenAIExamples.git
    cd GenAIExamples/ChatQnA
    docker build --no-cache -t opea/chatqna:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile .
    ```

Option 2. MegaService without Rerank
    To construct the Mega Service without Rerank, we utilize the [GenAIComps](https://github.com/opea-project/GenAIComps.git) microservice pipeline within the `chatqna_without_rerank.py` Python script. Build MegaService Docker image via below command:

    ```bash
    git clone https://github.com/opea-project/GenAIExamples.git
    cd GenAIExamples/ChatQnA
    docker build --no-cache -t opea/chatqna-without-rerank:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile.without_rerank .
    ```

#### Build UI Docker Image
Build frontend Docker image via below command:

```bash
cd GenAIExamples/ChatQnA/ui
docker build --no-cache -t opea/chatqna-ui:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile .
```

#### Build Conversational React UI Docker Image (Optional)
Build frontend Docker image that enables Conversational experience with ChatQnA megaservice via below command:

```bash
cd GenAIExamples/ChatQnA/ui
docker build --no-cache -t opea/chatqna-conversation-ui:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile.react .
```

#### Build Nginx Docker Image

```bash
cd GenAIComps
docker build -t opea/nginx:latest --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/third_parties/nginx/src/Dockerfile .
```
Then run the command `docker images`, you will have the following 5 Docker Images:
```
1. `opea/dataprep:latest`
2. `opea/retriever:latest`
3. `opea/chatqna:latest` or `opea/chatqna-without-rerank:latest`
4. `opea/chatqna-ui:latest`
5. `opea/nginx:latest`
```
###  Start Microservices
#### Required Models
By default, the embedding, reranking and LLM models are set to a default value as listed below:
```
| Service   | Model                               |
| --------- | ----------------------------------- |
| Embedding | BAAI/bge-base-en-v1.5               |
| Reranking | BAAI/bge-reranker-base              |
| LLM       | meta-llama/Meta-Llama-3-8B-Instruct |
```
Change the `xxx_MODEL_ID` below for your needs.
For users in China who are unable to download models directly from Huggingface, you can use [ModelScope](https://www.modelscope.cn/models) or a Huggingface mirror to download models. The vLLM can load the models either online or offline as described below:

1. Online
   ```bash
   export HF_TOKEN=${your_hf_token}
   export HF_ENDPOINT="https://hf-mirror.com"
   model_name="meta-llama/Meta-Llama-3-8B-Instruct"
   docker run -p 8008:80 -v ./data:/data --name vllm-service -e HF_ENDPOINT=$HF_ENDPOINT -e http_proxy=$http_proxy -e https_proxy=$https_proxy --shm-size 128g opea/vllm:latest --model $model_name --host 0.0.0.0 --port 80
   ```

2. Offline
    - Search your model name in ModelScope. For example, check [this page](https://modelscope.cn/models/LLM-Research/Meta-Llama-3-8B-Instruct/files) for model `Meta-Llama-3-8B-Instruct`.
    - Click on `Download this model` button, and choose one way to download the model to your local path `/path/to/model`.
    - Run the following command to start the LLM service.
     ```bash
     export HF_TOKEN=${your_hf_token}
     export model_path="/path/to/model"
     docker run -p 8008:80 -v $model_path:/data --name vllm-service --shm-size 128g opea/vllm:latest --model /data --host 0.0.0.0 --port 80
     ```

#### Setup Environment Variables
1. Set the required environment variables:

    ```bash
    # Example: host_ip="192.168.1.1"
    export host_ip="External_Public_IP"
    export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
    # Example: NGINX_PORT=80
    export NGINX_PORT=${your_nginx_port}
    ```

2. If you are in a proxy environment, also set the proxy-related environment variables:

    ```bash
    export http_proxy="Your_HTTP_Proxy"
    export https_proxy="Your_HTTPs_Proxy"
    # Example: no_proxy="localhost, 127.0.0.1, 192.168.1.1"
    export no_proxy="Your_No_Proxy",chatqna-xeon-ui-server,chatqna-xeon-backend-server,dataprep-pinecone-service,tei-embedding-service,retriever,tei-reranking-service,tgi-service,vllm-service
    ```

3. Set up other environment variables:

   ```bash
   source ./set_env.sh
   ```

#### Start all the services 
> Before running the docker compose command, you need to be in the folder that has the docker compose yaml file

    ```bash
    cd GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon/
    ```

> Start ChatQnA with Rerank Pipeline

    ```bash
    docker compose -f compose_<vectorDB>.yaml up -d
    ```

### Validate Microservices

Note, when verify the microservices by curl or API from remote client, please make sure the **ports** of the microservices are opened in the firewall of the cloud node.
Follow the instructions to validate MicroServices.

#### TEI Embedding Service

   ```bash
    curl ${host_ip}:6006/embed \
       -X POST \
       -d '{"inputs":"What is Deep Learning?"}' \
       -H 'Content-Type: application/json'
   ```

####  Retriever Microservice
   To consume the retriever microservice, you need to generate a mock embedding vector by Python script. The length of embedding vector is determined by the embedding model. Here we use the model `EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"`, which vector size is 768.
   Check the vector dimension of your embedding model, set `your_embedding` dimension equals to it. 

   ```bash
   export your_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")
   curl http://${host_ip}:7000/v1/retrieval \
     -X POST \
     -d "{\"text\":\"test\",\"embedding\":${your_embedding}}" \
     -H 'Content-Type: application/json'
   ```

####  TEI Reranking Service
   Skip for ChatQnA without Rerank pipeline

   ```bash
    curl http://${host_ip}:8808/rerank \
       -X POST \
       -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
       -H 'Content-Type: application/json'
   ```

####  LLM backend Service
   In the first startup, this service will take more time to download, load and warm up the model. After it's finished, the service will be ready. Try the command below to check whether the LLM serving is ready.

   ```bash
   docker logs vllm-service 2>&1 | grep complete
   ```

   If the service is ready, you will get the response like below.
   ```text
   INFO: Application startup complete.
   ```
   Then try the `cURL` command below to validate services.

   ```bash
    curl http://${host_ip}:9009/v1/chat/completions \
        -X POST \
        -d '{"model": "meta-llama/Meta-Llama-3-8B-Instruct", "messages": [{"role": "user", "content": "What is Deep Learning?"}], "max_tokens":17}' \
        -H 'Content-Type: application/json'
   ```

####  MegaService

   ```bash
    curl http://${host_ip}:8888/v1/chatqna -H "Content-Type: application/json" -d '{
          "messages": "What is the revenue of Nike in 2023?"
          }'
   ```

####  Nginx Service

   ```bash
    curl http://${host_ip}:${NGINX_PORT}/v1/chatqna \
       -H "Content-Type: application/json" \
       -d '{"messages": "What is the revenue of Nike in 2023?"}'
   ```

#### Dataprep Microservice（Optional）
If you want to update the default knowledge base, you can use the following commands:
Update Knowledge Base via Local File [nke-10k-2023.pdf](https://github.com/opea-project/GenAIComps/blob/v1.1/comps/retrievers/redis/data/nke-10k-2023.pdf). Or
click [here](https://raw.githubusercontent.com/opea-project/GenAIComps/v1.1/comps/retrievers/redis/data/nke-10k-2023.pdf) to download the file via any web browser Or run this command to get the file on a terminal.

```bash
wget https://raw.githubusercontent.com/opea-project/GenAIComps/v1.1/comps/retrievers/redis/data/nke-10k-2023.pdf
```

Upload:
```bash
    curl -X POST "http://${host_ip}:6007/v1/dataprep/ingest" \
        -H "Content-Type: multipart/form-data" \
        -F "files=@./nke-10k-2023.pdf"
```
This command updates a knowledge base by uploading a local file for processing. Update the file path according to your environment.
Add Knowledge Base via HTTP Links:
```bash
    curl -X POST "http://${host_ip}:6007/v1/dataprep/ingest" \
        -H "Content-Type: multipart/form-data" \
        -F 'link_list=["https://opea.dev"]'
```
This command updates a knowledge base by submitting a list of HTTP links for processing.
To delete the files/link you uploaded:
```bash
    curl -X POST "http://${host_ip}:6009/v1/dataprep/delete" \
        -d '{"file_path": "all"}' \
        -H "Content-Type: application/json"
```

# Tests for ChatQnA with new VectorDB 
This should go under  GenAIExamples/ChatQnA/tests

Test files to create - below examples give a skeleton for test files.

## Tests for Xeon

test_compose_<Vector_DB>_on_xeon.sh
	
    build_docker_images()
            echo "Building Docker Images...."
            
            if [ ! -d "GenAIComps" ] ; then
                git clone --single-branch --branch "${opea_branch:-"main"}" https://github.com/opea-project/GenAIComps.git
            fi
            
            service_list="dataprep embedding retriever reranking ChatQnA"
            docker compose -f build.yaml build ${service_list} --no-cache 
            docker pull ghcr.io/huggingface/text-embeddings-inference:cpu-1.5
            docker pull <Vector_DB> specific images
            docker images && sleep 1s
    	    echo "Docker images built!"

	start_services()
            echo "Starting Docker Services...."
       
            export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
            export RERANK_MODEL_ID="BAAI/bge-reranker-base"
            export TEI_EMBEDDING_ENDPOINT="http://${ip_address}:6006"
            export TEI_RERANKING_ENDPOINT="http://${ip_address}:8808"
            export TGI_LLM_ENDPOINT="http://${ip_address}:8008"
            export MILVUS_HOST=${ip_address}
            export HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN}
            export MEGA_SERVICE_HOST_IP=${ip_address}
            export EMBEDDING_SERVICE_HOST_IP=${ip_address}
            export RETRIEVER_SERVICE_HOST_IP=${ip_address}
            export RERANK_SERVICE_HOST_IP=${ip_address}
            export LLM_SERVICE_HOST_IP=${ip_address}
            export host_ip=${ip_address}
            export DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/ingest"
            export RERANK_TYPE="tei"
            export LOGFLAG=true

            # Start Docker Containers
            docker compose -f compose_<Vector_DB>.yaml up -d
            sleep 2m
            echo "Docker services started!"
	
    validate_megaservice()
            echo "===========Ingest data=================="
            
            local CONTENT=$(http_proxy="" curl -X POST "http://${ip_address}:6007/v1/dataprep/ingest" \
            -H "Content-Type: multipart/form-data" \
            -F 'link_list=["https://opea.dev/"]')
            local EXIT_CODE=$(validate "$CONTENT" "Data preparation succeeded" "dataprep-<Vector_DB>-service-xeon")
            echo "$EXIT_CODE"

            # Curl the Mega Service
            echo "================Testing retriever service: Text Request ================"

            local CONTENT=$(http_proxy="" curl http://${ip_address}:8889/v1/retrievaltool -X POST -H "Content-Type: application/json" -d '{
            "text": "Explain the OPEA project?"
            }')

## Tests for Gaudi

test_compose_<Vector_DB>_on_gaudi.sh

	build_docker_images()
            echo "Building Docker Images...."
                
            if [ ! -d "GenAIComps" ] ; then
                git clone --single-branch --branch "${opea_branch:-"main"}" https://github.com/opea-project/GenAIComps.git
            fi
                
            service_list="dataprep embedding retriever reranking ChatQnA"
            docker compose -f build.yaml build ${service_list} --no-cache 
            docker pull ghcr.io/huggingface/text-embeddings-inference:hpu-1.5
            docker pull <Vector_DB> specific images
            docker images && sleep 1s
            echo "Docker images built!"

	start_services()
            echo "Starting Docker Services...."
       
            export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
            export RERANK_MODEL_ID="BAAI/bge-reranker-base"
            export TEI_EMBEDDING_ENDPOINT="http://${ip_address}:6006"
            export TEI_RERANKING_ENDPOINT="http://${ip_address}:8808"
            export TGI_LLM_ENDPOINT="http://${ip_address}:8008"
            export MILVUS_HOST=${ip_address}
            export HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN}
            export MEGA_SERVICE_HOST_IP=${ip_address}
            export EMBEDDING_SERVICE_HOST_IP=${ip_address}
            export RETRIEVER_SERVICE_HOST_IP=${ip_address}
            export RERANK_SERVICE_HOST_IP=${ip_address}
            export LLM_SERVICE_HOST_IP=${ip_address}
            export host_ip=${ip_address}
            export DATAPREP_SERVICE_ENDPOINT="http://${host_ip}:6007/v1/dataprep/ingest"
            export RERANK_TYPE="tei"
            export LOGFLAG=true

            # Start Docker Containers
            docker compose -f compose_<Vector_DB>.yaml up -d
            sleep 2m
            echo "Docker services started!"
	
    validate_megaservice()
            echo "===========Ingest data=================="
            
            local CONTENT=$(http_proxy="" curl -X POST "http://${ip_address}:6007/v1/dataprep/ingest" \
            -H "Content-Type: multipart/form-data" \
            -F 'link_list=["https://opea.dev/"]')
            local EXIT_CODE=$(validate "$CONTENT" "Data preparation succeeded" "dataprep-<Vector_DB>-service-gaudi")
            echo "$EXIT_CODE"

            # Curl the Mega Service
            echo "================Testing retriever service: Text Request ================"

            local CONTENT=$(http_proxy="" curl http://${ip_address}:8889/v1/retrievaltool -X POST -H "Content-Type: application/json" -d '{
            "text": "Explain the OPEA project?"
            }')









