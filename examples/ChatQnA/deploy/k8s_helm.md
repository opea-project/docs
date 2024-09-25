# Multi-node on-prem deployment with  TGI on Xeon Scalable processors on a K8s cluster using Helm Charts

This deployment section covers multi-node on-prem deployment of the ChatQnA
example with OPEA comps to deploy using the TGI service. There are several
slice-n-dice ways to enable RAG with vectordb and LLM models, but here we will
be covering one option of doing it for convenience : we will be showcasing  how
to build an e2e chatQnA with Redis VectorDB and neural-chat-7b-v3-3 model,
deployed on a Kubernetes cluster. For more information on how to setup a Xeon based Kubernetes cluster along with the development pre-requisites,
please follow the instructions here (*** ### Kubernetes Cluster and Development Environment***). 
For a quick introduction on Helm Charts, visit the helm section in  (**getting started**)

## Overview

There are several ways to setup a ChatQnA use case. Here in this tutorial, we
will walk through how to enable the below list of microservices from OPEA
GenAIComps to deploy a multi-node TGI megaservice solution.
> **Note:** ChatQnA can also be deployed on a single node using Kubernetes, provided that all pods are configured to run on the same node.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with TGI

## Prerequisites

### Install Helm
First, ensure that Helm (version >= 3.15) is installed on your system. Helm is an essential tool for managing Kubernetes applications. It simplifies the deployment and management of Kubernetes applications using Helm charts. 
For detailed installation instructions, please refer to the [Helm Installation Guide](https://helm.sh/docs/intro/install/)

### Clone Repository 
First step is to clone the GenAIInfra which is the containerization and cloud native suite for OPEA, including artifacts to deploy ChatQnA in a cloud native way.

```bash
git clone https://github.com/opea-project/GenAIInfra.git
```
Checkout the release tag
```
cd GenAIInfra/helm-charts/
git checkout tags/v1.0
```
### HF Token
The example can utilize model weights from HuggingFace and langchain.

Setup your [HuggingFace](https://huggingface.co/) account and generate
[user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Setup the HuggingFace token
```
export HF_TOKEN="Your_Huggingface_API_Token"
```

### Proxy Settings
Make sure to setup Proxies if you are behind a firewall.
For services requiring internet access, such as the LLM microservice, embedding service, reranking service, and other backend services, proxy settings can be essential. These settings ensure services can download necessary content from the internet, especially when behind a corporate firewall.
Proxy can be set in the `values.yaml` file, like so:
Open the `values.yaml` file using an editor
```bash
vi GenAIInfra/helm-charts/chatqna/values.yaml
```
Update the following section and save file:
```yaml
global:
  http_proxy: "http://your-proxy-address:port"
  https_proxy: "http://your-proxy-address:port"
  no_proxy: "localhost,127.0.0.1,localaddress,.localdomain.com"
```
## Use Case Setup
The `GenAIInfra` repository utilizes a structured Helm chart approach, comprising a primary `Charts.yaml` and individual sub-charts for components like the LLM Service, Embedding Service, and Reranking Service. Each sub-chart includes its own `values.yaml` file, enabling specific configurations such as Docker image sources and deployment parameters. This modular design facilitates flexible, scalable deployment and easy management of the GenAI application suite within Kubernetes environments. For detailed configurations and common components, visit the [GenAIInfra common components directory](https://github.com/opea-project/GenAIInfra/tree/main/helm-charts/common).

This use case employs a tailored combination of Helm charts and `values.yaml` configurations to deploy the following components and tools:
|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   TGI        |Intel/neural-chat-7b-v3-3 |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |
Tools and models mentioned in the table are configurable either through the
environment variable or `values.yaml` 

Set a new [namespace](#create-and-set-namespace) and switch to it if needed

To enable UI, uncomment the lines `54-58` in `GenAIInfra/helm-charts/chatqna/values.yaml`:
```bash
chatqna-ui:
   image:
     repository: "opea/chatqna-ui"
     tag: "latest"
   containerPort: "5173"
```


Next, we will update the dependencies for all Helm charts in the specified directory and ensure the `chatqna` Helm chart is ready for deployment by updating its dependencies as defined in the `Chart.yaml` file.

```bash
# all Helm charts in the specified directory have their 
# dependencies up-to-date, facilitating consistent deployments.
./update_dependency.sh

# "chatqna" here refers to the directory name that contains the Helm 
# chart for the ChatQnA application 
helm dependency update chatqna
```

Set the necessary environment variables to setup the use case
```bash
export MODELDIR="/mnt/opea-models"  #export MODELDIR="null" if you don't want to cache the model.  
export MODELNAME="Intel/neural-chat-7b-v3-3"
export EMBEDDING_MODELNAME="BAAI/bge-base-en-v1.5"
export RERANKER_MODELNAME="BAAI/bge-reranker-base"
```

## Deploy the use case
In this tutorial, we will be deploying using Helm with the provided chart. The Helm install commands will initiate all the aforementioned services as Kubernetes pods.

```bash
helm install chatqna chatqna \
    --set global.HUGGINGFACEHUB_API_TOKEN=${HF_TOKEN} \
    --set global.modelUseHostPath=${MODELDIR} \
    --set tgi.LLM_MODEL_ID=${MODELNAME} \
    --set tei.EMBEDDING_MODEL_ID=${EMBEDDING_MODELNAME} \
    --set teirerank.RERANK_MODEL_ID=${RERANKER_MODELNAME}
```

**OUTPUT:**
```bash
NAME: chatqna
LAST DEPLOYED: Thu Sep  5 13:40:20 2024
NAMESPACE: chatqa
STATUS: deployed
REVISION: 1

```


### Validate microservice
#### Check the pod status
Check if all the pods launched via Helm have started.

For example, the ChatQnA deployment starts 12 Kubernetes services. Ensure that all associated pods are running, i.e., all the pods' statuses are 'Running'. To perform a quick sanity check, use the command `kubectl get pods` to see if all the pods are active.
```
NAME                                       READY   STATUS             RESTARTS        AGE
chatqna-5cd6b44f98-7tdnk                   1/1     Running            0               15m
chatqna-chatqna-ui-b9984f596-4pckn         1/1     Running            0               15m
chatqna-data-prep-7496bcf74-gj2fm          1/1     Running            0               15m
chatqna-embedding-usvc-79c9795545-5zpk5    1/1     Running            0               15m
chatqna-llm-uservice-564c497d65-kw6b2      1/1     Running            0               15m
chatqna-nginx-67fc749576-krmxs             1/1     Running            0               15m
chatqna-redis-vector-db-798f474769-5g7bh   1/1     Running            0               15m
chatqna-reranking-usvc-767545c6ff-966w2    1/1     Running            0               15m
chatqna-retriever-usvc-5ccf966546-446dd    1/1     Running            0               15m
chatqna-tei-7b987585c9-nwncb               1/1     Running            0               15m
chatqna-teirerank-fd745dcd5-md2l5          1/1     Running            0               15m
chatqna-tgi-675c4d79f6-cf4pq               1/1     Running            0               15m


```
> **Note:** Use `kubectl get pods -o wide` to check the nodes that the respective pods are running on


When issues are encountered with a pod in the Kubernetes deployment, there are two primary commands to diagnose and potentially resolve problems:
1. **Checking Logs**: To view the logs of a specific pod, which can provide insight into what the application is doing and any errors it might be encountering, use:
    ```bash
    kubectl logs [pod-name]
    ```
2. **Describing Pods**: For a detailed view of the pod's current state, its configuration, and its operational events, run:
	```bash
    kubectl describe pod [pod-name]
    ```
For example, if the status of the TGI service does not show 'Running', describe the pod using the name from the above table:
```bash
kubectl describe pod chatqna-tgi-778bb6598f-cv5cg
```
or check logs using:
```bash
kubectl logs chatqna-tgi-778bb6598f-cv5cg
```

## Interacting with ChatQnA deployment
This section will walk you through what are the different ways to interact with
the microservices deployed

Before starting the validation of microservices, check the network configuration of services using:
```bash
    kubectl get svc
   ```
   This command will display a list of services along with their network-related details such as cluster IP and ports. 
 ```
 NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
chatqna                   ClusterIP   100.XX.XXX.92    <none>        8888/TCP            37m
chatqna-chatqna-ui        ClusterIP   100.XX.XX.87     <none>        5174/TCP            37m
chatqna-data-prep         ClusterIP   100.XX.XXX.62    <none>        6007/TCP            37m
chatqna-embedding-usvc    ClusterIP   100.XX.XX.77     <none>        6000/TCP            37m
chatqna-llm-uservice      ClusterIP   100.XX.XXX.133   <none>        9000/TCP            37m
chatqna-nginx             NodePort    100.XX.XX.173    <none>        80:30700/TCP        37m
chatqna-redis-vector-db   ClusterIP   100.XX.X.126     <none>        6379/TCP,8001/TCP   37m
chatqna-reranking-usvc    ClusterIP   100.XX.XXX.82    <none>        8000/TCP            37m
chatqna-retriever-usvc    ClusterIP   100.XX.XXX.157   <none>        7000/TCP            37m
chatqna-tei               ClusterIP   100.XX.XX.143    <none>        80/TCP              37m
chatqna-teirerank         ClusterIP   100.XX.XXX.120   <none>        80/TCP              37m
chatqna-tgi               ClusterIP   100.XX.XX.133    <none>        80/TCP              37m

 ```
   To begin port forwarding, which maps a service's port from the cluster to local host for testing, use:
 ```bash
    kubectl port-forward svc/[service-name] [local-port]:[service-port]
   ```
   Replace `[service-name]`, `[local-port]`, and `[service-port]` with the appropriate values from your services list (as shown in the output given by `kubectl get svc`). This setup enables interaction with the microservice directly from the local machine. In another terminal, use `curl` commands to test the functionality and response of the service.

Use `ctrl+c` to end the port-forwarding to test other services.

### Dataprep Microservice（Optional）
Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-data-prep 6007:6007
```
Follow the below steps in a different terminal.

If you want to add/update the default knowledge base, you can use the following
commands. The dataprep microservice extracts the texts from variety of data
sources, chunks the data, embeds each chunk using embedding microservice and
store the embedded vectors in the redis vector database.

Local File `nke-10k-2023.pdf` Upload:

```
curl -X POST "http://localhost:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F "files=@./nke-10k-2023.pdf"
```

This command updates a knowledge base by uploading a local file for processing.
Update the file path according to your environment.

Add Knowledge Base via HTTP Links:

```
curl -X POST "http://localhost:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F 'link_list=["https://opea.dev"]'
```

This command updates a knowledge base by submitting a list of HTTP links for processing.

Also, you are able to get the file list that you uploaded:

```
curl -X POST "http://localhost:6007/v1/dataprep/get_file" \
     -H "Content-Type: application/json"

```

To delete the file/link you uploaded you can use the following commands:

#### Delete link
```
# The dataprep service will add a .txt postfix for link file

curl -X POST "http://localhost:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "https://opea.dev.txt"}' \
     -H "Content-Type: application/json"
```

#### Delete file

```
curl -X POST "http://localhost:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "nke-10k-2023.pdf"}' \
     -H "Content-Type: application/json"
```

#### Delete all uploaded files and links

```
curl -X POST "http://localhost:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "all"}' \
     -H "Content-Type: application/json"
```

### TEI Embedding Service
Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-tei 6006:80
```
Follow the below steps in a different terminal.

The TEI embedding service takes in a string as input, embeds the string into a
vector of a specific length determined by the embedding model and returns this
embedded vector.

```
curl http://localhost:6006/embed \
    -X POST \
    -d '{"inputs":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json'
```

In this example the embedding model used is "BAAI/bge-base-en-v1.5", which has a vector size of 768. So the output of the curl command is a embedded vector of
length 768.

### Embedding Microservice
Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-embedding-usvc 6000:6000
```
Follow the below steps in a different terminal.

The embedding microservice depends on the TEI embedding service. In terms of
input parameters, it takes in a string, embeds it into a vector using the TEI
embedding service and pads other default parameters that are required for the
retrieval microservice and returns it.
```
curl http://localhost:6000/v1/embeddings\
  -X POST \
  -d '{"text":"hello"}' \
  -H 'Content-Type: application/json'
```

### Retriever Microservice
Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-retriever-usvc 7000:7000
```
Follow the below steps in a different terminal.

To consume the retriever microservice, you need to generate a mock embedding
vector by Python script. The length of embedding vector is determined by the
embedding model. Here we use the
model EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5", which vector size is 768.

Check the vector dimension of your embedding model and set
`your_embedding` dimension equal to it.

```
export your_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")

curl http://localhost:7000/v1/retrieval \
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

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-teirerank 8808:80
```
Follow the below steps in a different terminal.

The TEI Reranking Service reranks the documents returned by the retrieval
service. It consumes the query and list of documents and returns the document
index based on decreasing order of the similarity score. The document
corresponding to the returned index with the highest score is the most relevant
document for the input query.
```
curl http://localhost:8808/rerank \
    -X POST \
    -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
    -H 'Content-Type: application/json'
```

Output is:  `[{"index":1,"score":0.9988041},{"index":0,"score":0.022948774}]`

### Reranking Microservice
Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-reranking-usvc 8000:8000
```
Follow the below steps in a different terminal.

The reranking microservice consumes the TEI Reranking service and pads the
response with default parameters required for the llm microservice.

```
curl http://localhost:8000/v1/reranking\
  -X POST \
  -d '{"initial_query":"What is Deep Learning?", "retrieved_docs": \
     [{"text":"Deep Learning is not..."}, {"text":"Deep learning is..."}]}' \
  -H 'Content-Type: application/json'
```

The input to the microservice is the `initial_query` and a list of retrieved
documents and it outputs the most relevant document to the initial query along
with other default parameter such as temperature, `repetition_penalty`,
`chat_template` and so on. We can also get top n documents by setting `top_n` as one
of the input parameters. For example:

```
curl http://localhost:8000/v1/reranking\
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

### vLLM and TGI Service

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-tgi 9009:80
```
Follow the below steps in a different terminal.

```
curl http://localhost:9009/generate \
  -X POST \
  -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":17, "do_sample": true}}' \
  -H 'Content-Type: application/json'

```

TGI service generate text for the input prompt. Here is the expected result from TGI:

```
{"generated_text":"We have all heard the buzzword, but our understanding of it is still growing. It’s a sub-field of Machine Learning, and it’s the cornerstone of today’s Machine Learning breakthroughs.\n\nDeep Learning makes machines act more like humans through their ability to generalize from very large"}
```

**NOTE**: After launch the TGI, it takes few minutes for TGI server to load LLM model and warm up.

If you get

```
curl: (7) Failed to connect to localhost port 8008 after 0 ms: Connection refused
```

and the log shows model warm up, please wait for a while and try it later.

```
2024-06-05T05:45:27.707509646Z 2024-06-05T05:45:27.707361Z  WARN text_generation_router: router/src/main.rs:357: `--revision` is not set
2024-06-05T05:45:27.707539740Z 2024-06-05T05:45:27.707379Z  WARN text_generation_router: router/src/main.rs:358: We strongly advise to set it to a known supported commit.
2024-06-05T05:45:27.852525522Z 2024-06-05T05:45:27.852437Z  INFO text_generation_router: router/src/main.rs:379: Serving revision bdd31cf498d13782cc7497cba5896996ce429f91 of model Intel/neural-chat-7b-v3-3
2024-06-05T05:45:27.867833811Z 2024-06-05T05:45:27.867759Z  INFO text_generation_router: router/src/main.rs:221: Warming up model
```

### LLM Microservice

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-llm-uservice 9000:9000
```
Follow the below steps in a different terminal.

```
curl http://localhost:9000/v1/chat/completions\
  -X POST \
  -d '{"query":"What is Deep Learning?","max_new_tokens":17,"top_k":10,"top_p":0.95,\
     "typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}' \
  -H 'Content-Type: application/json'

```

You will get generated text from LLM:

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

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kkubectl port-forward svc/chatqna 8888:8888
```
Follow the below steps in a different terminal.

```
curl http://localhost:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model": "Intel/neural-chat-7b-v3-3",
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
## Launch UI
### Basic UI
To access the frontend, open the following URL in your browser: 
`http://{k8s-node-ip-address}:${port}`
You can find the NGINX port using the following command:
```bash
export port=$(kubectl get service chatqna-nginx --output='jsonpath={.spec.ports[0].nodePort}')
echo $port
```
Open a browser to access `http://<k8s-node-ip-address>:${port}`
 
 By default, the UI runs on port 5173 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the `GenAIInfra/helm-charts/chatqna/values.yaml` file as shown below:
```
chatqna-ui:
   image:
     repository: "opea/chatqna-ui"
     tag: "latest"
   containerPort: "5173"
```
### Stop the services
Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:
```
helm uninstall chatqna
```