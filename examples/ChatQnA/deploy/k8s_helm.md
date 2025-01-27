# Multi-node on-prem deployment with TGI on Xeon Scalable processors on a K8s cluster using Helm

This deployment section covers multi-node on-prem deployment of the ChatQnA example with OPEA components using the TGI service. While one may customize the RAG application with a choice of vector database, the LLM model used, this guide will show how to build an e2e chatQnA application using the Redis VectorDB and the neural-chat-7b-v3-3 model, deployed on a Kubernetes cluster using Helm. 

For more information on how to setup a Xeon-based Kubernetes cluster along with the development pre-requisites, refer to [Kubernetes Cluster and Development Environment](k8s_getting_started.md#kubernetes-cluster-and-development-environment) and for a [quick introduction to Helm Charts](k8s_getting_started.md#using-helm-charts-to-deploy).

## Overview

In this ChatQnA  tutorial, we
will walk through how to enable the below list of microservices from OPEA
GenAIComps to deploy a multi-node TGI-based service solution.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with TGI

> **Note:** ChatQnA can also be deployed on a single node using Kubernetes provided there are adequate resources for all the associated pods, namely CPU and memory and, no constraints such as affinity, anti-affinity, or taints.

## Prerequisites

### Hardware Prerequisites
For cloud deployments, the ChatQnA pipeline in this guide has been tested on an AWS `m7i.8xlarge` single node instance, which provides `32 vCPUs`, `128 GiB` memory and upgraded to `100 GB` of disk space. While the default deployment uses only `~24 GiB` of memory, similar instance types with at least 32 vCPUs and 32 GiB of memory are recommended to ensure smooth performance.

By switching to bf16 from the default fp32, the memory requirement can be further relaxed. Instructions to switch to bf16 are provided in the [Use Case Setup](#use-case-setup) section below.

### Install Helm
First, ensure that Helm (version >= 3.15) is installed on your system. Helm is an essential tool for managing Kubernetes applications. It simplifies the deployment and management of Kubernetes applications using Helm charts. 
For detailed installation instructions, refer to the [Helm Installation Guide](https://helm.sh/docs/intro/install/)

### Clone Repository 
The next step is to clone the GenAIInfra which is the containerization and cloud-native suite for OPEA, including artifacts to deploy ChatQnA in a cloud-native way.

```bash
git clone https://github.com/opea-project/GenAIInfra.git
```
Checkout the release tag
```
cd GenAIInfra/helm-charts/
git checkout tags/v1.2
```
### HF Token
The example can utilize model weights from HuggingFace.

Setup your [HuggingFace](https://huggingface.co/) account and generate
[user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Setup the HuggingFace token
```
export HF_TOKEN="Your_Huggingface_API_Token"
```

### Proxy Settings

If you are behind a corporate VPN, proxy settings must be added for services requiring internet access, such as the LLM microservice, embedding service, reranking service, and other backend services.
Proxy can be set in the `values.yaml`.
Open the `values.yaml` file using an editor
```bash
vi chatqna/values.yaml
```
Update the following section and save file:
```yaml
# chatqna/values.yaml
global:
  http_proxy: "http://your-proxy-address:port"
  https_proxy: "http://your-proxy-address:port"
  no_proxy: "localhost,127.0.0.1,localaddress,.localdomain.com"
```
## Use Case Setup

The `GenAIInfra` repository utilizes a structured Helm chart approach, comprising a primary `Charts.yaml` and individual sub-charts for components like the LLM Service, Embedding Service, and Reranking Service. Each sub-chart includes its own `values.yaml` file, enabling specific configurations such as container image name/version and deployment parameters. This modular design facilitates flexible, scalable deployment and easy management of the GenAI application suite within Kubernetes environments. For detailed configurations and common components, visit the [GenAIInfra common components directory](https://github.com/opea-project/GenAIInfra/tree/main/helm-charts/common).

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

Set a new [namespace](k8s_getting_started.md#create-and-set-namespace) and switch to it if needed

To enable UI, uncomment the following lines in `GenAIInfra/helm-charts/chatqna/values.yaml`:
```bash
chatqna-ui:
   image:
     repository: "opea/chatqna-ui"
     tag: "latest"
   containerPort: "5173"
```

Next, we will update the dependencies for all Helm charts in the specified directory and ensure the `chatqna` Helm chart is ready for deployment by updating its dependencies as defined in the `Chart.yaml` file.

```bash
# All Helm charts in the specified directory have their 
# dependencies up-to-date, facilitating consistent deployments.
./update_dependency.sh

# "chatqna" here refers to the directory name that contains the Helm 
# chart for the ChatQnA application 
helm dependency update chatqna
```

To use the bfloat16 data type for the LLM in TGI, modify the `values.yaml` file located in `GenAIInfra/helm-charts/common/tgi/`. Uncomment or add the following line:

```yaml
extraCmdArgs: ["--dtype","bfloat16"]
```
This configuration ensures that TGI processes LLM operations in bfloat16 precision, enabling lower-precision computations for improved performance and reduced memory usage. Bfloat16 operations are accelerated using Intel® AMX, the built-in AI accelerator on 4th Gen Intel® Xeon® Scalable processors and later.

Set the necessary environment variables to set up the use case
```bash
export MODELDIR=""  #export MODELDIR="/mnt/opea-models" if you want to cache the model.  
export MODELNAME="Intel/neural-chat-7b-v3-3"
export EMBEDDING_MODELNAME="BAAI/bge-base-en-v1.5"
export RERANKER_MODELNAME="BAAI/bge-reranker-base"
```

> **Note:**
> 
> Setting `MODELDIR` to an empty string will download the models without sharing them among worker nodes. This configuration is intended as a quick setup for testing in a single-node environment.
> 
> In a multi-node environment, go to every k8s worker node to make sure that a ${MODELDIR} directory exists and is writable.
> 
> Another option is to use k8s persistent volume to share the model data files. For more information see [Using Persistent Volume](https://github.com/opea-project/GenAIInfra/blob/main/helm-charts/README.md#using-persistent-volume).

## Deploy the use case
The `helm install` command will initiate all the aforementioned services such as Kubernetes pods.

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
It takes a few minutes for all the microservices to get up and running. Go to the next section which is [Validate Microservices](#validate-microservices) to verify that the deployment is successful.


### Validate microservice
#### Check the pod status
To check if all the pods have started, run:

```bash
kubectl get pods
``` 
You should expect a similar output as below:
```
NAME                                      READY   STATUS    RESTARTS      AGE
chatqna-chatqna-ui-77dbdfc949-6dtms        1/1     Running   0          5m7s
chatqna-data-prep-798f59f447-4frqt         1/1     Running   0          5m7s
chatqna-df57cc766-t6lkg                    1/1     Running   0          5m7s
chatqna-nginx-5dd47bfc7d-54x96             1/1     Running   0          5m7s
chatqna-redis-vector-db-7f489b6bb6-mvzbw   1/1     Running   0          5m7s
chatqna-retriever-usvc-6695979d67-z5jgx    1/1     Running   0          5m7s
chatqna-tei-769dc796c-gh5vx                1/1     Running   0          5m7s
chatqna-teirerank-54f58c596c-76xqz         1/1     Running   0          5m7s
chatqna-tgi-7b5556d46d-pnzph               1/1     Running   0          5m7s
```
>**Note:** Use `kubectl get pods -o wide` to check the nodes that the respective pods are running on

For example, the ChatQnA deployment starts 9 Kubernetes services. Ensure that all associated pods are running, i.e., all the pods' statuses are 'Running'. To perform a quick sanity check, use the command `kubectl get pods` to see if all the pods are active.

When issues are encountered with a pod in the Kubernetes deployment, there are two primary commands to diagnose and potentially resolve problems:
1. **Checking Logs**: To view the logs of a specific pod, which can provide insight into what the application is doing and any errors it might be encountering use:
    ```bash
    kubectl logs <pod-name>
    ```
2. **Describing Pods**: For a detailed view of the pod's current state, its configuration, and its operational events, run:
	```bash
    kubectl describe pod <pod-name>
    ```
For example, if the status of the TGI service does not show 'Running', describe the pod using the name from the above table. In our example the pod name is chatqna-tgi-778bb6598f-cv5cg.
```bash
kubectl describe pod chatqna-tgi-778bb6598f-cv5cg
```
Or check logs using:
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
chatqna                   ClusterIP   10.108.186.198   <none>        8888/TCP            8m16s
chatqna-chatqna-ui        ClusterIP   10.102.80.123    <none>        5173/TCP            8m16s
chatqna-data-prep         ClusterIP   10.110.143.212   <none>        6007/TCP            8m16s
chatqna-nginx             NodePort    10.100.224.12    <none>        80:30304/TCP        8m16s
chatqna-redis-vector-db   ClusterIP   10.205.9.19      <none>        6379/TCP,8001/TCP   8m16s
chatqna-retriever-usvc    ClusterIP   10.202.3.15      <none>        7000/TCP            8m16s
chatqna-tei               ClusterIP   10.105.204.12    <none>        80/TCP              8m16s
chatqna-teirerank         ClusterIP   10.115.146.21    <none>        80/TCP              8m16s
chatqna-tgi               ClusterIP   10.108.195.244   <none>        80/TCP              8m16s
kubernetes                ClusterIP   10.92.0.100      <none>        443/TCP             11d
 ```
To access the services running in your Kubernetes cluster from your local machine, you can set up port forwarding with kubectl:
 ```bash
    kubectl port-forward svc/[service-name] [local-port]:[service-port] &
   ```
   Replace `[service-name]`, `[local-port]`, and `[service-port]` with the appropriate values from your services list (as shown in the output given by `kubectl get svc`). This setup enables interaction with the microservice directly from the local machine. In another terminal, use `curl` commands to test the functionality and response of the service. `&` runs the process in the background.

Use `ctrl+c` to end the port-forwarding to test other services.


### Accessing the ChatQnA application

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna 8888:8888 &
```
Test the service:

```
curl http://localhost:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model": "Intel/neural-chat-7b-v3-3",
     "messages": "What is OPEA?"
     }'
```
>**NOTE:** In the curl command, in addition to our prompt, we are specifying the LLM model to use.

Here is the output for your reference:

```bash
data: b' O'
data: b'PE'
data: b'A'
data: b' stands'
data: b' Organization'
data: b' of'
data: b' Public'
data: b' Em'
data: b'ploy'
data: b'ees'
data: b' of'
data: b' Alabama'
.
.
.
data: b''
data: b''
data: [DONE]
```

Which is essentially the following sentence:
```
OPEA stands for Organization of Public Employees of Alabama. It is a labor union representing public employees in the state of Alabama, working to protect their rights and interests.
```
In the upcoming sections, we will see how this answer can be improved with RAG.

### Dataprep Microservice
Use the following command to forward traffic from your local machine to the data-prep service running in the Kubernetes cluster, which allows uploading documents to provide a more domain-specific context:
```bash
kubectl port-forward svc/chatqna-data-prep 6007:6007 &
```
Test the service:

If you want to add to or update the default knowledge base, you can use the following
commands. The dataprep microservice extracts the text from the provided data
source (multiple data source types are supported such as PDF, Word, and URLs), chunks the data, embeds each chunk using the embedding microservice, and stores the embedded vectors in the vector database, in our current example a Redis Vector database.

This example leverages the OPEA document for its RAG-based content. You can download the [OPEA document](https://opea-project.github.io/latest/_downloads/41c91aec1d47f20ca22350daa8c2cadc/what_is_opea.pdf) and upload it using the UI.


Local File `what_is_opea.pdf` Upload:

```
curl -X POST "http://localhost:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F "files=@./what_is_opea.pdf"
```

This command updates a knowledge base by uploading a local file for processing.
Update the file path according to your environment.

You should see the following output after successful execution:
```
{"status":200,"message":"Data preparation succeeded"}
```
Refer to [advanced use of dataprep microservice] (#dataprep-microservice-advanced) to learn more.

### Accessing ChatQnA application after custom data upload

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna 8888:8888 &
```
Similarly, Test the service:

```
curl http://localhost:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model": "Intel/neural-chat-7b-v3-3",
     "messages": "What is OPEA?"
     }'
```
After uploading the pdf with information about OPEA, we can see that the pdf is being used as a context to answer the question correctly:

```bash
data: b' O'
data: b'PE'
data: b'A'
data: b' ('
data: b'Open'
data: b' Platform'
data: b' for'
data: b' Enterprise'
data: b' AI'
data: b')',
.
.
.
data: b' systems'
data: b'.'
data: b''
data: b''
data: [DONE]
```

The above output has been parsed into the below sentence which shows how the LLM has picked up the right context to answer the question correctly after the document upload:
```
Open Platform for Enterprise AI (Open Platform for Enterprise AI) is a framework that focuses on creating and evaluating open, multi-provider, robust, and composable generative AI (GenAI) solutions. It aims to facilitate the implementation of enterprise-grade composite GenAI solutions, particularly Retrieval Augmented Generative AI (RAG), by simplifying the integration of secure, performant, and cost-effective GenAI workflows into business systems.
```

### TEI Embedding Service
Use the following command to forward traffic from your local machine to the TEI service running in your Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-tei 6006:80 &
```
Test the service:

The TEI embedding service takes in a string as input, embeds the string into a
vector of a specific length determined by the embedding model and returns this
embedded vector.

```
curl http://localhost:6006/embed \
    -X POST \
    -d '{"inputs":"What is Deep Learning?"}' \
    -H 'Content-Type: application/json'
```

In this example, the embedding model used is "BAAI/bge-base-en-v1.5", which has a vector size of 768. So the output of the `curl` command is an embedded vector of
length 768.


### Retriever Microservice
Use the following command to forward traffic from your local machine to the Retriever service running in your Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-retriever-usvc 7000:7000 &
```
Test the service:

To consume the retriever microservice, you need to generate a mock embedding
vector by Python script. The length of the embedding vector is determined by the
embedding model. Here we use the
model EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5", which creates a vector of size 768.

Check the vector dimension of your embedding model and set
`your_embedding` dimension equal to it.

```
export your_embedding=$(python3 -c "import random; embedding = [random.uniform(-1, 1) for _ in range(768)]; print(embedding)")

curl http://localhost:7000/v1/retrieval \
  -X POST \
  -d "{\"text\":\"test\",\"embedding\":${your_embedding}}" \
  -H 'Content-Type: application/json'
```
The output of the retriever microservice comprises of a unique ID for the
request, initial query, or the input to the retrieval microservice, a list of top
`n` retrieved documents relevant to the input query, and top_n where n refers to
the number of documents to be returned.

The output is retrieved text that is relevant to the input data:
```
{"id":"13617fc8ac716a9ca5df036fd297b9ad","retrieved_docs":[{"downstream_black_list":[],"id":"7e6f2e6584947f293d6d40cccb7ef58d","text":"applications.\nMicroservices: Flexible and Scalable Architecture\nThe GenAI Microservices documentation describes a suite of microservices. Each microservice is\ndesigned to perform a specific function or task within the application architecture. By breaking\ndown the system into these smaller, self-contained services, microservices promote modularity,\nflexibility, and scalability. This modular approach allows developers to independently develop,\ndeploy, and scale individual components of the application, making it easier to maintain and\nevolve over time. All of the microservices are containerized, allowing cloud native deployment.Megaservices: A Comprehensive Solution\nMegaservices are higher-level architectural constructs composed of one or more microservices.\nUnlike individual microservices, which focus on specific tasks or functions, a megaservice\norchestrates multiple microservices to deliver a comprehensive solution. Megaservices\nencapsulate complex business logic and workflow orchestration, coordinating the interactions\nbetween various microservices to fulfill specific application requirements. This approach enables\nthe creation of modular yet integrated applications. You can find a collection of use case-based\napplications in the GenAI Examples documentation\nGateways: Customized Access to Mega- and Microservices\nThe Gateway serves as the interface for users to access a megaservice, providing customized"},{"downstream_black_list":[],"id":"94197f8afc84ccabd1c95df2cfc91e6f","text":"The Gateway serves as the interface for users to access a megaservice, providing customized\naccess based on user requirements. It acts as the entry point for incoming requests, routing\nthem to the appropriate microservices within the megaservice architecture.\nGateways support API definition, API versioning, rate limiting, and request transformation,\nallowing for fine-grained control over how users interact with the underlying Microservices. By\nabstracting the complexity of the underlying infrastructure, Gateways provide a seamless and\nuser-friendly experience for interacting with the Megaservice.\nNext Step\nLinks to:\nGetting Started Guide\nGet Involved with the OPEA Open Source Community\nBrowse the OPEA wiki, mailing lists, and working groups:\nhttps://wiki.lfaidata.foundation/display/DL/OPEA+Home \nOpen Platform for Enterprise AI (OPEA) Framework Draft Proposal."},{"downstream_black_list":[],"id":"9636f9b479f2412bc8ce177db502c8c9","text":"Latest » OPEA Overview\nOPEA Overview\nOPEA (Open Platform for Enterprise AI) is a framework that enables the creation and evaluation\nof open, multi-provider, robust, and composable generative AI (GenAI) solutions. It harnesses\nthe best innovations across the ecosystem while keeping enterprise-level needs front and\ncenter.\nOPEA simplifies the implementation of enterprise-grade composite GenAI solutions, starting\nwith a focus on Retrieval Augmented Generative AI (RAG). The platform is designed to facilitate\nefficient integration of secure, performant, and cost-effective GenAI workflows into business\nsystems and manage its deployments, leading to quicker GenAI adoption and business value.\nThe OPEA platform includes:\nDetailed framework of composable microservices building blocks for state-of-the-art GenAI\nsystems including LLMs, data stores, and prompt engines\nArchitectural blueprints of retrieval-augmented GenAI component stack structure and end-\nto-end workflows\nMultiple micro- and megaservices to get your GenAI into production and deployed\nA four-step assessment for grading GenAI systems around performance, features,\ntrustworthiness and enterprise-grade readiness\nOPEA Project Architecture\nOPEA uses microservices to create high-quality GenAI applications for enterprises, simplifying\nthe scaling and deployment process for production. These microservices leverage a service\ncomposer that assembles them into a megaservice thereby creating real-world Enterprise AI\napplications."}],"initial_query":"test","top_n":1}
```
### TEI Reranking Service

Use the following command to forward traffic from your local machine to the Reranking service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-teirerank 8808:80 &
```
Test the service:

The TEI Reranking Service reranks the documents returned by the retrieval
service. It consumes the query and list of documents and returns the document
indices based on the decreasing order of the similarity score. The document
corresponding to the returned index with the highest score is the most relevant
document for the input query.
```
curl http://localhost:8808/rerank \
    -X POST \
    -d '{"query":"What is Deep Learning?", "texts": ["Deep Learning is not...", "Deep learning is..."]}' \
    -H 'Content-Type: application/json'
```

Output is:  `[{"index":1,"score":0.9988041},{"index":0,"score":0.022948774}]`


### TGI Service

Use the following command to forward traffic from your local machine to the service running in your Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-tgi 9009:80 &
```
Test the service:

```
curl http://localhost:9009/generate \
  -X POST \
  -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":17, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

TGI service generates text for the input prompt. Here is the expected result from TGI:

```
{"generated_text":"We have all heard the buzzword, but our understanding of it is still growing. It’s a sub-field of Machine Learning, and it’s the cornerstone of today’s Machine Learning breakthroughs.\n\nDeep Learning makes machines act more like humans through their ability to generalize from very large"}
```

**NOTE**: After TGI service is started, it takes a few minutes to load the LLM model and warm up, before it reaches the `Ready` state.

If you get

```
curl: (7) Failed to connect to localhost port 8008 after 0 ms: Connection refused
```

And the log shows the model warm-up, please wait for a while and retry.

```
2024-06-05T05:45:27.707509646Z 2024-06-05T05:45:27.707361Z  WARN text_generation_router: router/src/main.rs:357: `--revision` is not set
2024-06-05T05:45:27.707539740Z 2024-06-05T05:45:27.707379Z  WARN text_generation_router: router/src/main.rs:358: We strongly advise to set it to a known supported commit.
2024-06-05T05:45:27.852525522Z 2024-06-05T05:45:27.852437Z  INFO text_generation_router: router/src/main.rs:379: Serving revision bdd31cf498d13782cc7497cba5896996ce429f91 of model Intel/neural-chat-7b-v3-3
2024-06-05T05:45:27.867833811Z 2024-06-05T05:45:27.867759Z  INFO text_generation_router: router/src/main.rs:221: Warming up model
```

### Dataprep Microservice (Advanced)
Once you have set up port forward for the dataprep service, you can upload, delete, and list documents.

Add Knowledge Base via HTTP Links:

```
curl -X POST "http://localhost:6007/v1/dataprep" \
     -H "Content-Type: multipart/form-data" \
     -F 'link_list=["https://opea.dev"]'
```

This command updates a knowledge base by submitting a list of HTTP links for processing.

To get a list of uploaded files:

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
     -d '{"file_path": "what_is_opea.pdf"}' \
     -H "Content-Type: application/json"
```

#### Delete all uploaded files and links

```
curl -X POST "http://localhost:6007/v1/dataprep/delete_file" \
     -d '{"file_path": "all"}' \
     -H "Content-Type: application/json"
```



## Launch UI
### Basic UI via NodePort
To access the frontend, open the following URL in your browser: 
`http://{k8s-node-ip-address}:${port}`
You can find the NGINX port using the following command:
```bash
kubectl get service chatqna-nginx
```
Which shows the Nginx port as follows:
```
NAME            TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
chatqna-nginx   NodePort   10.201.220.120   <none>        80:30304/TCP   16h
```
We can see that it is serving at port `30304` based on this configuration via a NodePort.

The next step is to get the `<k8s-node-ip-address>` by running:
```bash
kubectl get nodes -o wide
```
The command shows internal IPs for all the nodes in the cluster:
```
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
minikube   Ready    control-plane   11d   v1.31.0   190.128.49.1   <none>        Ubuntu 22.04.4 LTS   5.15.0-124-generic   docker://27.2.0
```
When using a NodePort, all the nodes in the cluster will be listening at the specified port, which is  `30304` in this example. The `<k8s-node-ip-address>` can be found under INTERNAL-IP. Here it is `190.128.49.1`.

Open a browser to access `http://<k8s-node-ip-address>:${port}`.
From the configuration shown above, it would be `http://190.128.49.1:30304`

### Basic UI via Port Forwarding

Alternatively, You can also choose to use port forwarding as shown previously using:
```bash
kubectl port-forward service/chatqna-nginx 8080:80 &
```
And open a browser to access `http://localhost:8080`
 
 Visit this [link](https://opea-project.github.io/latest/getting-started/README.html#interact-with-chatqna) to see how to interact with the UI. 

### Stop the services
Once you are done with the entire pipeline and wish to stop and remove all the resources, use the command below:
```
helm uninstall chatqna
```
To stop all port-forwarding processes and free up the ports, run the following command:
```
pkill -f "kubectl port-forward"
```
