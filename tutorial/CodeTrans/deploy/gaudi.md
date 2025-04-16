# # Single node on-prem deployment on Gaudi AI Accelerator

This deployment section covers the single-node on-prem deployment of the CodeTrans example. It will show how to build a code translation service using the `mistralai/Mistral-7B-Instruct-v0.3` model deployed on Intel® Gaudi® AI Accelerator. To quickly learn about OPEA and set up the required hardware and software, follow the instructions in the [Getting Started](../../../getting-started/README.md) section.

## Overview

In this tutorial, we will walk through how to enable the following microservices from OPEA GenAIComps to deploy a single node Text Generation megaservice solution for code translation:

1. LLM with TGI
2. Nginx Service

The solution demonstrates using the Mistral-7B-Instruct-v0.3 model on the Intel® Gaudi® AI Accelerator for translating code between different programming languages. We will go through how to set up docker containers to start the microservices and megaservice. Users can input code in one programming language and get it translated into another language. The solution is deployed with a basic UI accessible through both direct port and Nginx.

## Prerequisites

To run the UI on a web browser external to the host machine such as a laptop, the following port(s) need to be port forwarded when using SSH to log in to the host machine:
- 7777: CodeTrans megaservice port

This port is used for `BACKEND_SERVICE_IP` defined in the `set_env.sh` for this example inside the `docker compose` folder. Specifically, for CodeTrans, append the following to the ssh command: 
```bash
-L 7777:localhost:7777
```

Set up a workspace and clone the [GenAIExamples](https://github.com/opea-project/GenAIExamples) GitHub repo.
```bash
export WORKSPACE=<Path>
cd $WORKSPACE
git clone https://github.com/opea-project/GenAIExamples.git # GenAIExamples
```

**Optional** It is recommended to use a stable release version by setting `RELEASE_VERSION` to a **number only** (i.e. 1.0, 1.1, etc) and checkout that version using the tag. Otherwise, by default, the main branch with the latest updates will be used.
```bash
export RELEASE_VERSION=<Release_Version> # Set desired release version - number only
cd GenAIExamples
git checkout tags/v${RELEASE_VERSION}
cd ..
```

The example utilizes model weights from HuggingFace. Set up a [HuggingFace](https://huggingface.co/) account and apply for model access to `Mistral-7B-Instruct-v0.3` which is a gated model. To obtain access for using the model, visit the [model site](https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.3) and click on `Agree and access repository`. 

Next, generate a [user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Set an environment variable with the HuggingFace token:
```bash
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

Set the `host_ip` environment variable to deploy the microservices on the endpoints enabled with ports:
```bash
export host_ip=$(hostname -I | awk '{print $1}')
```

Set up a desired port for Nginx:
```bash
# Example: NGINX_PORT=80
export  NGINX_PORT=${your_nginx_port}
```

For machines behind a firewall, set up the proxy environment variables:
```bash
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Use Case Setup

CodeTrans will use the following GenAIComps and corresponding tools. Tools and models mentioned in the table are configurable either through environment variables in the `set_env.sh` or `compose.yaml` file.

| Use Case Components | Tools         | Model                                | Service Type         |
|---------------------|---------------|--------------------------------------|----------------------|
| LLM                 | TGI           | mistralai/Mistral-7B-Instruct-v0.3   | OPEA Microservice    |
| UI                  |               | NA                                   | Gateway Service      |
| Ingress             | Nginx         | NA                                   | Gateway Service      |

Set the necessary environment variables to set up the use case. To swap out models, modify `set_env.sh` before running it. For example, the environment variable `LLM_MODEL_ID` can be changed to another model by specifying the HuggingFace model card ID.

To run the UI on a web browser on a laptop, modify `BACKEND_SERVICE_IP` to use `localhost` or `127.0.0.1` instead of `host_ip` inside `set_env.sh` for the backend to properly receive data from the UI.

Run the `set_env.sh` script.
```bash
cd $WORKSPACE/GenAIExamples/CodeTrans/docker_compose
source ./set_env.sh
```

## Deploy the Use Case

Run `docker compose` with the provided YAML file to start all the services mentioned above as containers. The vLLM or TGI service can be used for CodeTrans.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
cd $WORKSPACE/GenAIExamples/CodeTrans/docker_compose/intel/cpu/xeon
docker compose -f compose.yaml up -d
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
cd $WORKSPACE/GenAIExamples/CodeTrans/docker_compose/intel/cpu/xeon
docker compose -f compose_tgi.yaml up -d
```
:::
::::

### Check Env Variables

After running `docker compose`, check for warning messages for environment variables that are **NOT** set. Address them if needed. 

    ubuntu@xeon-vm:~/GenAIExamples/CodeTrans/docker_compose/intel/cpu/xeon$ docker compose -f ./compose.yaml up -d

    WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
    WARN[0000] The "http_proxy" variable is not set. Defaulting to a blank string. 

Check if all the containers launched via `docker compose` are running i.e. each container's `STATUS` is `Up` and `Healthy`.

Run this command to see this info:
```bash
docker ps -a
```

Sample output:
```bash
CONTAINER ID   IMAGE                                 COMMAND                  CREATED         STATUS                   PORTS                                       NAMES
a6d83e9fb44f   opea/nginx:latest                     "/docker-entrypoint.…"   8 minutes ago   Up 26 seconds            0.0.0.0:80->80/tcp, :::80->80/tcp           codetrans-gaudi-nginx-server
42af29c8a8b6   opea/codetrans-ui:latest              "docker-entrypoint.s…"   8 minutes ago   Up 27 seconds            0.0.0.0:5173->5173/tcp, :::5173->5173/tcp   codetrans-gaudi-ui-server
d995d76e7b52   opea/codetrans:latest                 "python code_transla…"   8 minutes ago   Up 27 seconds            0.0.0.0:7777->7777/tcp, :::7777->7777/tcp   codetrans-gaudi-backend-server
f40e954b107e   opea/llm-textgen:latest               "bash entrypoint.sh"     8 minutes ago   Up 27 seconds            0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   llm-textgen-gaudi-server
0eade4fe0637   ghcr.io/huggingface/tgi-gaudi:2.0.6   "text-generation-lau…"   8 minutes ago   Up 8 minutes (healthy)   0.0.0.0:8008->80/tcp, :::8008->80/tcp       codetrans-tgi-service
```

Each docker container's log can also be checked using:

```bash
docker logs <CONTAINER_ID OR CONTAINER_NAME>
```

## Validate Microservices

This section will walk through the different ways to interact with the microservices deployed.

### vLLM or TGI Service

In the first startup, this service will take more time to download, load, and warm up the model. After it is finished, the service will be ready.

Try the command below to check whether the LLM serving is ready.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
# vLLM service
docker logs codetrans-xeon-vllm-service 2>&1 | grep complete
# If the service is ready, you will get the response like below.
INFO:     Application startup complete.
```
:::
:::{tab-item} TGI
:sync: TGI

Then try the `cURL` command to verify the vLLM or TGI service:
```bash
curl http://${host_ip}:8008/generate \
  -X POST \
  -d '{"inputs":"    ### System: Please translate the following Golang codes into  Python codes.    ### Original codes:    '\'''\'''\''Golang    \npackage main\n\nimport \"fmt\"\nfunc main() {\n    fmt.Println(\"Hello, World!\");\n    '\'''\'''\''    ### Translated codes:","parameters":{"max_new_tokens":17, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

The vLLM or TGI service generates text for the input prompt. Here is the expected result:
```bash
{"generated_text":"'''Python\nprint(\"Hello, World!\")"}
```

### LLM Microservice

This service handles the core language model operations. Send a direct request to translate a simple "Hello World" program from Go to Python:
```bash
curl http://${host_ip}:9000/v1/chat/completions\
  -X POST \
  -d '{"query":"    ### System: Please translate the following Golang codes into  Python codes.    ### Original codes:    '\'''\'''\''Golang    \npackage main\n\nimport \"fmt\"\nfunc main() {\n    fmt.Println(\"Hello, World!\");\n    '\'''\'''\''    ### Translated codes:"}' \
  -H 'Content-Type: application/json'
```

Sample output:
```bash
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

### CodeTrans MegaService

The CodeTrans megaservice orchestrates the entire translation process. Test it with a simple code translation request:
```bash
curl http://${host_ip}:7777/v1/codetrans \
    -H "Content-Type: application/json" \
    -d '{"language_from": "Golang","language_to": "Python","source_code": "package main\n\nimport \"fmt\"\nfunc main() {\n    fmt.Println(\"Hello, World!\");\n}"}'
```

Sample output:
```bash
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"        "}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" Python"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121307,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"        "}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" print"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"(\""}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"Hello"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":","}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" World"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"!"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\")"}],"created":1737121308,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"\n"}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":"        "}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"","index":0,"logprobs":null,"text":" ```"}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":null}
data: {"id":"","choices":[{"finish_reason":"eos_token","index":0,"logprobs":null,"text":"</s>"}],"created":1737121309,"model":"mistralai/Mistral-7B-Instruct-v0.3","object":"text_completion","system_fingerprint":"2.4.0-sha-0a655a0-intel-cpu","usage":{"completion_tokens":18,"prompt_tokens":74,"total_tokens":92,"completion_tokens_details":null,"prompt_tokens_details":null}}
data: [DONE]
```

The megaservice streams each segment of the response. Each line contains JSON that includes a `text` field. Combining the `text` values in order will reconstruct the translated code. In this example, the final code is simply:
```bash
print("Hello, World!")
```

### Nginx Service

The Nginx service acts as a reverse proxy and load balancer for the application. To verify it is properly routing requests, send the same translation request through Nginx:
```bash
curl http://${host_ip}:${NGINX_PORT}/v1/codetrans \
    -H "Content-Type: application/json" \
    -d '{"language_from": "Golang","language_to": "Python","source_code": "package main\n\nimport \"fmt\"\nfunc main() {\n    fmt.Println(\"Hello, World!\");\n}"}'
```
The expected output is the same as the megaservice output.

Each of these endpoints should return a successful response with the translated Python code. If any of these tests fail, check the corresponding service logs for more details.

## Launch UI

### Basic UI

To access the frontend user interface (UI), the primary method is through the Nginx reverse proxy service. Open the following URL in a web browser: http://${host_ip}:${NGINX_PORT}. This provides a stable and secure access point to the UI.

Alternatively, the UI can be accessed directly using its internal port. This method bypasses the Nginx proxy and can be used for testing or troubleshooting purposes. To access the UI directly, open the following URL in a web browser: http://${host_ip}:5173. By default, the UI runs on port 5173.

To change the port used to access the UI directly (not through Nginx), modify the ports section of the `compose.yaml` file by replacing `YOUR_HOST_PORT` with the desired port:

```yaml
codetrans-gaudi-ui-server:
 image: ${REGISTRY:-opea}/codetrans-ui:${TAG:-latest}
 container_name: codetrans-gaudi-ui-server
 depends_on:
 - codetrans-gaudi-backend-server
 ports:
 - "YOUR_HOST_PORT:5173" # Change YOUR_HOST_PORT to your desired port
```
After making this change, rebuild and restart the containers for the change to take effect. 

### Stop the Services

To stop and remove all the containers, use the commands below:

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
cd $WORKSPACE/GenAIExamples/CodeTrans/docker_compose/intel/hpu/gaudi
docker compose -f compose.yaml down
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
cd $WORKSPACE/GenAIExamples/CodeTrans/docker_compose/intel/hpu/gaudi
docker compose -f compose_tgi.yaml down
```
:::
::::
