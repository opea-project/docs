# Single node on-prem deployment with TGI on Xeon Scalable processors

This deployment section covers the single-node on-prem deployment of the CodeTrans example with OPEA comps using the Text Generation service based on TGI. The solution demonstrates building a code translation service using the `mistralai/Mistral-7B-Instruct-v0.3` model deployed on Intel® Xeon® Scalable processors. To quickly learn about OPEA in just 5 minutes and set up the required hardware and software, please follow the instructions in the [Getting Started](https://opea-project.github.io/latest/getting-started/README.html) section.

## Overview

In this tutorial, we will walk through how to enable the following microservices from OPEA GenAIComps to deploy a single node Text Generation megaservice solution for code translation:

1. LLM with TGI
2. Nginx Service

The solution demonstrates using the Mistral-7B-Instruct-v0.3 model on Intel Xeon Scalable processors to translate code between different programming languages. We will go through setting up Docker containers to start the microservices and megaservice. Users can input code in one programming language and get it translated to another. The solution is deployed with a basic UI accessible through both direct port and Nginx.

## Prerequisites

The first step is to clone the GenAIExamples and GenAIComps. GenAIComps are fundamental components used to build examples you find in GenAIExamples and deploy them as microservices.

```
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
```
The examples utilize model weights from HuggingFace.
Set up your [HuggingFace](https://huggingface.co/) account and 
apply for model access to `Mistral-7B-Instruct-v0.3` which is a gated model. To obtain access for using the model, visit the [model site](https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.3) and click on `Agree and access repository`. 

Next, generate [user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Setup the HuggingFace token

```
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

The example requires you to set the `host_ip` to deploy the microservices on the endpoint enabled with ports. Set the host_ip env variable.

```
export host_ip=$(hostname -I | awk '{print $1}')
```

Make sure to set Proxies if you are behind a firewall.

```bash
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Prepare (Building / Pulling) Docker images

This step involves either building or pulling four required Docker images. Each image serves a specific purpose in the CodeTrans architecture.

::::::{tab-set}

:::::{tab-item} Pull
:sync: Pull

If you decide to pull the docker containers and not build them locally, you can proceed to [Use Case Setup](#use-case-setup). where all the necessary containers will be pulled in from the docker hub.
:::::
:::::{tab-item} Build
:sync: Build

From within the `GenAIComps` folder, check out the release tag.
```
cd GenAIComps
git checkout tags/v1.2
```

### Build LLM Image

First, build the Text Generation LLM service image:

```bash
docker  build  -t  opea/llm-textgen:latest  --build-arg  https_proxy=$https_proxy  \
--build-arg http_proxy=$http_proxy -f comps/llms/src/text-generation/Dockerfile .
```

>**Note**: `llm-textgen` uses Text Generation Inference (TGI) which is pulled automatically via the docker compose file in the next steps.

### Build Nginx Image

Build the Nginx service image that will handle routing:

```bash
docker  build  -t  opea/nginx:latest  --build-arg  https_proxy=$https_proxy  \
--build-arg http_proxy=$http_proxy -f comps/third_parties/nginx/src/Dockerfile .

```

### Build MegaService Image

The Megaservice is a pipeline that channels data through different microservices, each performing varied tasks. We define the different microservices and the flow of data between them in the  `code_translation.py`  file, in this example, CodeTrans MegaService formats the input code and language parameters into a prompt template, sends it to the LLM microservice, and returns the translated code. You can also add newer or remove some microservices and customize the megaservice to suit the needs.

Build the megaservice image for this use case.

```bash
git  clone  https://github.com/opea-project/GenAIExamples.git
cd  GenAIExamples/CodeTrans
git checkout tags/v1.2
```
```
docker  build  -t  opea/codetrans:latest  --build-arg  https_proxy=$https_proxy  \
--build-arg http_proxy=$http_proxy -f Dockerfile .
```

### Build UI Image

Build the UI service image:

```bash
cd  GenAIExamples/CodeTrans/ui
docker  build  -t  opea/codetrans-ui:latest  --build-arg  https_proxy=$https_proxy  \
--build-arg http_proxy=$http_proxy -f ./docker/Dockerfile .
```

### Sanity Check

Before proceeding, verify that you have all required Docker images by running `docker images`. You should see the following images:

* opea/llm-textgen:latest
* opea/codetrans:latest
* opea/codetrans-ui:latest
* opea/nginx:latest

:::::
::::::

## Use Case Setup

The use case will use the following combination of the GenAIComps with the tools.

| Use Case Components | Tools         | Model                                | Service Type         |
|---------------------|---------------|--------------------------------------|----------------------|
| LLM                 | TGI           | mistralai/Mistral-7B-Instruct-v0.3   | OPEA Microservice    |
| UI                  |               | NA                                   | Gateway Service      |
| Ingress             | Nginx         | NA                                   | Gateway Service      |

Tools and models mentioned in the table are configurable either through the environment variable or `compose.yaml`

Set the necessary environment variables to set the use case.

```bash
cd GenAIExamples/CodeTrans/docker_compose
git checkout tags/v1.2
source ./set_env.sh
```
Set up a desired port for Nginx:
```bash
# Example: NGINX_PORT=80
export  NGINX_PORT=${your_nginx_port}
```

## Deploy the use case

In this tutorial, we will be deploying via docker compose with the provided YAML file. The docker compose instructions should start all the above-mentioned services as containers.

```bash
cd intel/cpu/xeon
docker compose up -d
```

### Validate microservice

#### Check Env Variables

Check the startup log by `docker compose -f ./compose.yaml logs`.
The warning messages print out the variables if they are **NOT** set.

ubuntu@xeon-vm:~/GenAIExamples/CodeTrans/docker_compose/intel/cpu/xeon$ docker compose -f ./compose.yaml up -d

WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "http_proxy" variable is not set. Defaulting to a blank string. 

#### Check the container status

Check if all the containers launched via docker compose have started.
For example, the CodeTrans example starts 5 docker containers (services), check these docker containers are all running, i.e., all the containers `STATUS` are `Up`.

To do a quick sanity check, try `docker ps -a` to see if all the containers are running.

```
| CONTAINER ID | IMAGE                                                             | COMMAND                   | CREATED         | STATUS                            | PORTS                                      | NAMES                           |
|--------------|-------------------------------------------------------------------|---------------------------|----------------|------------------------------------|---------------------------------------------|---------------------------------|
| 0744c6693a64 | opea/nginx:latest                                                | `/docker-entrypoint.…`    | 20 minutes ago | Up 9 minutes                       | 0.0.0.0:80->80/tcp, :::80->80/tcp           | codetrans-xeon-nginx-server     |
| 1e9c8c900843 | opea/codetrans-ui:latest                                         | `docker-entrypoint.s…`    | 20 minutes ago | Up 9 minutes                       | 0.0.0.0:5173->5173/tcp, :::5173->5173/tcp   |            codetrans-xeon-ui-server        |
| 3ed57de43648 | opea/codetrans:latest                                            | `python code_transla…`    | 20 minutes ago | Up 9 minutes                       | 0.0.0.0:7777->7777/tcp, :::7777->7777/tcp   | codetrans-xeon-backend-server   |
| 29d0fe6382dd | opea/llm-textgen:latest                                          | `bash entrypoint.sh`      | 20 minutes ago | Up 9 minutes                       | 0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   | llm-textgen-server              |
| e1b37ad9e078 | ghcr.io/huggingface/text-generation-inference:2.4.0-intel-cpu    | `text-generation-lau…`    | 20 minutes ago | Up 13 minutes (healthy)            | 0.0.0.0:8008->80/tcp, [::]:8008->80/tcp     | codetrans-tgi-service           |

```

## Interacting with CodeTrans deployment

In this section, you will walk through the different ways to interact with the deployed microservices.

### TGI Service

In the first startup, this service will take more time to download the model files. After it's finished, the service will be ready.

Try the command below to check whether the LLM serving is ready.
```
docker logs ${CONTAINER_ID} | grep Connected
```
If the service is ready, you will get a response like below.

```
2024-09-03T02:47:53.402023Z INFO text_generation_router::server: router/src/server.rs:2311: Connected
```
```bash
curl  http://${host_ip}:8008/generate  \
-X POST \
-d  '{"inputs":" ### System: Please translate the following Golang codes into Python codes. ### Original codes: '\'''\'''\''Golang \npackage main\n\nimport \"fmt\"\nfunc main() {\n fmt.Println(\"Hello, World!\");\n '\'''\'''\'' ### Translated codes:","parameters":{"max_new_tokens":17, "do_sample": true}}'  \
-H 'Content-Type: application/json'
```

TGI service generates text for the input prompt. Here is the expected result from TGI:
 
```
{"generated_text":"'''Python\nprint(\"Hello, World!\")"}
```
**NOTE**: After launching TGI, it takes a few minutes for the TGI server to load the LLM model and warm up.

### Text Generation Microservice

This service handles the core language model operations. You can validate it's working by sending a direct request to translate a simple "Hello World" program from Go to Python:

```bash
curl http://${host_ip}:9000/v1/chat/completions \
  -X POST \
  -d '{
        "query": "### System: Please translate the following Golang codes into Python codes. ### Original codes: ```Golang\npackage main\n\nimport \"fmt\"\nfunc main() {\n fmt.Println(\"Hello, World!\");\n}\n``` ### Translated codes:",
        "max_tokens": 17
      }' \
  -H 'Content-Type: application/json'
```
The expected output is as shown below:
```
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737123223,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737123223,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"``"}],"created":1737123223,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"`"}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"Py"}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"thon"}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"print"}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"(\""}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"Hello"}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":","}],"created":1737123224,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" World"}],"created":1737123225,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"!"}],"created":1737123225,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\")"}],"created":1737123225,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737123225,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"``"}],"created":1737123225,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"length","index":0,"logprobs":null,"text":"`"}],"created":1737123225,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":{"completion_tokens":17,"prompt_tokens":58,"total_tokens":75,"completion_tokens_details":null,"prompt_tokens_details":null}}
data: [DONE]
```

### MegaService

The CodeTrans megaservice orchestrates the entire translation process. Test it with a simple code translation request:

```bash
curl  http://${host_ip}:7777/v1/codetrans  \
-H "Content-Type: application/json" \
-d  '{"language_from": "Golang","language_to": "Python","source_code": "package main\n\nimport \"fmt\"\nfunc main() {\n fmt.Println(\"Hello, World!\");\n}"}'
```
When you send this request, you’ll receive a streaming response from the MegaService. It will appear line by line like so:
```
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"        "}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" Python"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"        "}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" print"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"(\""}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"Hello"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":","}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" World"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"!"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\")"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"        "}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" ```"}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"eos_token","index":0,"logprobs":null,"text":"</s>"}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":{"completion_tokens":18,"prompt_tokens":74,"total_tokens":92,"completion_tokens_details":null,"prompt_tokens_details":null}}
data: [DONE]
```
Within this output, each line contains JSON that includes a `text` field. Once you combine the `text` values in order, you’ll reconstruct the translated code. In this example, the final code is simply:
```
print("Hello, World!")
```
This demonstrates how the MegaService streams each segment of the response, which you can then piece together to get the complete translation.

### Nginx Service

The Nginx service acts as a reverse proxy and load balancer for the application. You can verify it's properly routing requests by sending the same translation request through Nginx:

```bash
curl  http://${host_ip}:${NGINX_PORT}/v1/codetrans  \
-H "Content-Type: application/json" \
-d  '{"language_from": "Golang","language_to": "Python","source_code": "package main\n\nimport \"fmt\"\nfunc main() {\n fmt.Println(\"Hello, World!\");\n}"}'
```
The expected output is the same as the MegaService output.

Each of these endpoints should return a successful response with the translated Python code. If any of these tests fail, check the corresponding service logs for more details.

## Check the docker container logs

Following is an example of debugging using Docker logs:

Check the log of the container using:

`docker logs <CONTAINER ID> -t`

Check the log using `docker logs e1b37ad9e078 -t`.

```
2024-06-05T01:30:30.695934928Z error: a value is required for '--model-id <MODEL_ID>' but none was supplied

2024-06-05T01:30:30.697123534Z

2024-06-05T01:30:30.697148330Z For more information, try '--help'.
```
The log indicates the `MODEL_ID` is not set.

View the docker input parameters in `./CodeTrans/docker_compose/intel/cpu/xeon/compose.yaml`
```
tgi-service:
    image: ghcr.io/huggingface/text-generation-inference:2.4.0-intel-cpu
    container_name: codetrans-tgi-service
    ports:
      - "8008:80"
    volumes:
      - "./data:/data"
    shm_size: 1g
    environment:
      no_proxy: ${no_proxy}
      http_proxy: ${http_proxy}
      https_proxy: ${https_proxy}
      HF_TOKEN: ${HUGGINGFACEHUB_API_TOKEN}
      host_ip: ${host_ip}
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://$host_ip:8008/health || exit 1"]
      interval: 10s
      timeout: 10s
      retries: 100
    command: --model-id ${LLM_MODEL_ID} --cuda-graphs 0
```
The input `MODEL_ID` is `${LLM_MODEL_ID}`

Check environment variable `LLM_MODEL_ID` is set correctly, and spelled correctly.

Set the `LLM_MODEL_ID` then restart the containers.
You can also check overall logs with the following command, where the
`compose.yaml` is the MegaService docker-compose configuration file.
```
docker compose -f ./docker_compose/intel/cpu/xeon/compose.yaml logs
```
## Launch UI

### Basic UI

To access the frontend user interface (UI), the primary method is through the Nginx reverse proxy service. Open the following URL in your browser: http://${host_ip}:${NGINX_PORT}. This provides a stable and secure access point to the UI. The value of ${NGINX_PORT} has been defined in the earlier steps.

Alternatively, you can access the UI directly using its internal port. This method bypasses the Nginx proxy and can be used for testing or troubleshooting purposes. To access the UI directly, open the following URL in your browser: http://${host_ip}:5173. By default, the UI runs on port 5173.

If you need to change the port used to access the UI directly (not through Nginx), modify the ports section of the `compose.yaml` file:

```
codetrans-xeon-ui-server:
  image: ${REGISTRY:-opea}/codetrans-ui:${TAG:-latest}
  container_name: codetrans-xeon-ui-server
  depends_on:
    - codetrans-xeon-backend-server
  ports:
    - "YOUR_HOST_PORT:5173" # Change YOUR_HOST_PORT to your desired port
```
Remember to replace YOUR_HOST_PORT with your preferred host port number. After making this change, you will need to rebuild and restart your containers for the change to take effect. 


### Stop the services

Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:

```
docker compose -f compose.yaml down
```