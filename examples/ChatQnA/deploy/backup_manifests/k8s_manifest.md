# Multi-node on-prem deployment with TGI on Xeon Scalable processors on a K8s cluster using Helm Charts
<pod-name> in helm update

This deployment section covers multi-node on-prem deployment of the ChatQnA example with OPEA comps to deploy using the TGI service. There are several slice-n-dice ways to enable RAG with vectordb and LLM models, but here we will be covering one option of doing it for convenience: we will be showcasing how to build an e2e chatQnA with Redis VectorDB and neural-chat-7b-v3-3 model, deployed on a Kubernetes cluster using Helm. For more information on how to setup a Xeon based Kubernetes cluster along with the development pre-requisites, follow the instructions here [Kubernetes Cluster and Development Environment](./k8s_getting_started.md#kubernetes-cluster-and-development-environment).
For a quick introduction on deploying using Mainfest files, visit the  `Using Kubernetes Manifest to Deploy`  section in  [Getting Started with Kubernetes for ChatQnA](./k8s_getting_started.md)

## Overview

There are several ways to setup a ChatQnA use case. Here in this tutorial, we
will walk through how to enable the below list of microservices from OPEA
[GenAIComps](https://github.com/opea-project/GenAIComps) to deploy a multi-node TGI megaservice solution.

1. Data Prep
2. Embedding
3. Retriever
4. Reranking
5. LLM with TGI

> **Note:** ChatQnA can also be deployed on a single node using Kubernetes, provided that all pods are configured to run on the same node.

## Prerequisites

### Clone Repository 
To set up the workspace for deploying ChatQnA via Kubernetes, start by cloning the `GenAIExamples` repository and navigate to the ChatQnA Kubernetes manifests directory:

```bash
https://github.com/opea-project/GenAIExamples.git
```
Checkout the release tag
```
cd GenAIExamples/ChatQnA/kubernetes/intel/cpu/xeon/manifest
git checkout tags/v1.1
```
### Bfloat16 Inference Optimization
We recommend using newer CPUs, such as 4th Gen Intel Xeon Scalable processors (code-named Sapphire Rapids) and later, that support the bfloat16 data type. If your hardware includes such CPUs and your model is compatible with bfloat16, adding the `--dtype bfloat16` argument to the HuggingFace `text-generation-inference` server can significantly reduce memory usage by half and provide a moderate speed boost. This change has already been configured in the `chatqna_bf16.yaml` file. To use it, follow these steps:

Run `kubectl get nodes` and identify the nodes in your cluster with BFloat16 support and label the nodes to schedule the service on it automatically:

```bash
kubectl label node <node-name> node-type=node-bfloat16
```

>**Note:**  The manifest folder has several configuration pipelines that can be deployed for ChatQnA. In this example, we'll use the `chatqna_bf16.yaml` configuration. You can use `chatqna.yaml` instead if you don't have BFloat16 support in your nodes.

### HF Token
The example can utilize model weights from HuggingFace and langchain.

Setup your [HuggingFace](https://huggingface.co/) account and generate
[user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Add the HuggingFace token to the manifest
```bash
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
# write the token to appropriate places in the manifest file
sed -i "s/insert-your-huggingface-token-here/${HUGGINGFACEHUB_API_TOKEN}/g" chatqna_bf16.yaml
```

### Proxy Settings
If you are behind a corporate VPN, proxy settings must be added for services requiring internet access, such as the LLM microservice, embedding service, reranking service, and other backend services.
Proxy settings can be set in the `ConfigMap` section across the manifest file. One example for `chatqna-tei-config` is shown below.

To configure proxy settings for the Text Embedding Inference (TEI) microservice using a `ConfigMap` in the `chatqna_bf16.yaml` manifest, open `chatqna_bf16.yaml` in an editor and populate the `http_proxy`, `https_proxy` and `no_proxy` fields under `data` marked by `#1`, `#2` and `#3` as follows:

```bash
vi chatqna_bf16.yaml
```
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: chatqna-tei-config
  labels:
    helm.sh/chart: tei-1.0.0
    app.kubernetes.io/name: tei
    app.kubernetes.io/instance: chatqna
    app.kubernetes.io/version: "cpu-1.5"
    app.kubernetes.io/managed-by: Helm
data:
  MODEL_ID: "BAAI/bge-base-en-v1.5"
  PORT: "2081"
  http_proxy: "http://your-proxy-address:port"       #1
  https_proxy: "http://your-proxy-address:port"      #2
  no_proxy: "localhost,127.0.0.1,localaddress,.localdomain.com"  #3
  NUMBA_CACHE_DIR: "/tmp"
  TRANSFORMERS_CACHE: "/tmp/transformers_cache"
  HF_HOME: "/tmp/.cache/huggingface"
  MAX_WARMUP_SEQUENCE_LENGTH: "512"
```
## Use Case Setup

As mentioned the use case will use the following combination of the [GenAIComps](https://github.com/opea-project/GenAIComps) with the tools:

|use case components | Tools |   Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|Data Prep            |  LangChain   | NA                       |OPEA Microservice |
|VectorDB             |  Redis       | NA                       |Open source service|
|Embedding            |   TEI        | BAAI/bge-base-en-v1.5    |OPEA Microservice |
|Reranking            |   TEI        | BAAI/bge-reranker-base   | OPEA Microservice |
|LLM                  |   TGI        |Intel/neural-chat-7b-v3-3 |OPEA Microservice |
|UI                   |              | NA                       | Gateway Service |

Tools and models mentioned in the table are configurable either through the
`chatqna_bf16.yaml` 


## Deploy the use case

Set a new [namespace](#create-and-set-namespace) and switch to it if needed and run:

  ```bash
    kubectl apply -f chatqna_bf16.yaml
```

It takes a few minutes for all the microservices to be up and running. Go to the next section which is [Validate Microservices](#validate-microservices) to verify that the deployment is successful.



### Validate microservice
#### Check the pod status
To check if all the pods have started, run:

```bash
kubectl get pods
``` 
You should expect a similar output as below:
```
NAME                                       READY   STATUS    RESTARTS   AGE
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
> [!NOTE] 
> Use `kubectl get pods -o wide` to check the nodes that the respective pods are running on

The ChatQnA deployment starts 9 Kubernetes services. Ensure that all associated pods are running, i.e., all the pods' statuses are 'Running'. 

When issues are encountered with a pod in the Kubernetes deployment, there are two primary commands to diagnose and potentially resolve problems:
1. **Checking Logs**: To view the logs of a specific pod, which can provide insight into what the application is doing and any errors it might be encountering, use:
    ```bash
    kubectl logs <pod-name>
    ```
2. **Describing Pods**: For a detailed view of the pod's current state, its configuration, and its operational events, run:
	```bash
    kubectl describe pod <pod-name>
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
   To begin port forwarding, which maps a service's port from the cluster to local host for testing, use:
 ```bash
    kubectl port-forward svc/[service-name] [local-port]:[service-port]
   ```
   Replace `[service-name]`, `[local-port]`, and `[service-port]` with the appropriate values from your services list (as shown in the output given by `kubectl get svc`). This setup enables interaction with the microservice directly from the local machine. In another terminal, use `curl` commands to test the functionality and response of the service.

Use `ctrl+c` to end the port-forwarding to test other services.

### MegaService Before RAG Dataprep

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna 8888:8888
```
Follow the below steps in a different terminal.

```
curl http://localhost:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model": "Intel/neural-chat-7b-v3-3",
     "messages": "What is the revenue of Nike in 2023?"
     }'

```
Here is the output for your reference:
```bash
data: b' O', data: b'PE', data: b'A', data: b' stands', data: b' for', data: b' Organization', data: b' of', data: b' Public', data: b' Em', data: b'ploy', data: b'ees', data: b' of', data: b' Alabama', data: b'.', data: b' It', data: b' is', data: b' a', data: b' labor', data: b' union', data: b' representing', data: b' public', data: b' employees', data: b' in', data: b' the', data: b' state', data: b' of', data: b' Alabama', data: b',', data: b' working', data: b' to', data: b' protect', data: b' their', data: b' rights', data: b' and', data: b' interests', data: b'.', data: b'', data: b'', data: [DONE]
```
which is essentially the following sentence:
```
OPEA stands for Organization of Public Employees of Alabama. It is a labor union representing public employees in the state of Alabama, working to protect their rights and interests.
```
In the upcoming sections we will see how this answer can be improved with RAG.

### Dataprep Microservice
Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna-data-prep 6007:6007
```
Follow the below steps in a different terminal.

If you want to add/update the default knowledge base, you can use the following
commands. The dataprep microservice extracts the texts from variety of data
sources, chunks the data, embeds each chunk using embedding microservice and
store the embedded vectors in the redis vector database.

this example leverages the OPEA document for its RAG based content. You can download the [OPEA document](https://opea-project.github.io/latest/_downloads/41c91aec1d47f20ca22350daa8c2cadc/what_is_opea.pdf) and upload it using the UI.


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
For advanced usage of the dataprep microservice refer [here](#dataprep-microservice-%28advanced%29)

### MegaService After RAG Dataprep

Use the following command to forward traffic from your local machine to the service running in the Kubernetes cluster:
```bash
kubectl port-forward svc/chatqna 8888:8888
```
Similarly, follow the below steps in a different terminal.

```
curl http://localhost:8888/v1/chatqna -H "Content-Type: application/json" -d '{
     "model": "Intel/neural-chat-7b-v3-3",
     "messages": "What is OPEA?"
     }'

```
After uploading the pdf with information about OPEA, we can see that the pdf is being used as a context to answer the question correctly:

```bash
data: b' O', data: b'PE', data: b'A', data: b' (', data: b'Open', data: b' Platform', data: b' for', data: b' Enterprise', data: b' AI', data: b')', data: b' is', data: b' a', data: b' framework', data: b' that', data: b' focuses', data: b' on', data: b' creating', data: b' and', data: b' evalu', data: b'ating', data: b' open', data: b',', data: b' multi', data: b'-', data: b'provider', data: b',', data: b' robust', data: b',', data: b' and', data: b' compos', data: b'able', data: b' gener', data: b'ative', data: b' AI', data: b' (', data: b'Gen', data: b'AI', data: b')', data: b' solutions', data: b'.', data: b' It', data: b' aims', data: b' to', data: b' facilitate', data: b' the', data: b' implementation', data: b' of', data: b' enterprise', data: b'-', data: b'grade', data: b' composite', data: b' Gen', data: b'AI', data: b' solutions', data: b',', data: b' particularly', data: b' Ret', data: b'riev', data: b'al', data: b' Aug', data: b'ment', data: b'ed', data: b' Gener', data: b'ative', data: b' AI', data: b' (', data: b'R', data: b'AG', data: b'),', data: b' by', data: b' simpl', data: b'ifying', data: b' the', data: b' integration', data: b' of', data: b' secure', data: b',', data: b' perform', data: b'ant', data: b',', data: b' and', data: b' cost', data: b'-', data: b'effective', data: b' Gen', data: b'AI', data: b' work', data: b'fl', data: b'ows', data: b' into', data: b' business', data: b' systems', data: b'.', data: b'', data: b'', data: [DONE]
```
The above output has been parsed into the below sentence which shows how the LLM has picked up the right context to answer the question correctly after the document upload:
```
OPEN Platform for Enterprise AI (Open Platform for Enterprise AI) is a framework that focuses on creating and evaluating open, multi-provider, robust, and composable generative AI (GenAI) solutions. It aims to facilitate the implementation of enterprise-grade composite GenAI solutions, particularly Retrieval Augmented Generative AI (RAG), by simplifying the integration of secure, performant, and cost-effective GenAI workflows into business systems.
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


### TGI Service

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

### Dataprep Microservice (Advanced)

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
### Basic UI
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

Next step is to get the `<k8s-node-ip-address>` by running:
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

Alternatively, You can also choose to use port forwarding as shown previously using:
```bash
kubectl port-forward service/chatqna-nginx 8080:80
```
and open a browser to access `http://localhost:8080`
 
 Visit this [link](https://opea-project.github.io/latest/getting-started/README.html#:~:text=tei%2Dembedding%2Dserver%20%20%20%20%20%20%20%20%20%7C-,Interact%20with%20ChatQnA,-%C2%B6) to see how to interact with the UI.
### Stop the services
Once you are done with the entire pipeline and wish to stop and remove all the pods, use the command below:
```
kubectl delete deployments --all
```