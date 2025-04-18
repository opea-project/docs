# Single node on-prem deployment on Gaudi AI Accelerator

This section covers single-node on-prem deployment of the CodeGen example. It will show how to deploy an end-to-end CodeGen solution with the `Qwen2.5-Coder-32B-Instruct` model running on Intel® Gaudi® AI Accelerators. To quickly learn about OPEA and set up the required hardware and software, follow the instructions in the [Getting Started](../../../getting-started/README.md) section. 

## Overview

The CodeGen use case uses a single microservice called LLM with model serving done with vLLM or TGI.

This solution is designed to demonstrate the use of the `Qwen2.5-Coder-32B-Instruct` model for code generation on Intel® Gaudi® AI Accelerators. The steps will involve setting up Docker containers, taking text input as the prompt, and generating code. Although multiple versions of the UI can be deployed, this tutorial will focus solely on the default version.

## Prerequisites

To run the UI on a web browser external to the host machine such as a laptop, the following port(s) need to be forwarded when using SSH to log in to the host machine:
- 7778: CodeGen megaservice port

This port is used for `BACKEND_SERVICE_ENDPOINT` defined in the `set_env.sh` for this example inside the `docker compose` folder. Specifically, for CodeGen, append the following to the ssh command: 
```bash
-L 7778:localhost:7778
```

Set up a workspace and clone the [GenAIExamples](https://github.com/opea-project/GenAIExamples) GitHub repo.
```bash
export WORKSPACE=<Path>
cd $WORKSPACE
git clone https://github.com/opea-project/GenAIExamples.git
```

**Optional** It is recommended to use a stable release version by setting `RELEASE_VERSION` to a **number only** (i.e. 1.0, 1.1, etc) and checkout that version using the tag. Otherwise, by default, the main branch with the latest updates will be used.
```bash
export RELEASE_VERSION=<Release_Version> #  Set desired release version - number only
cd GenAIExamples
git checkout tags/v${RELEASE_VERSION}
cd ..
```

Set up a [HuggingFace](https://huggingface.co/) account and generate a [user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token). The [Qwen2.5-Coder-32B-Instruct](https://huggingface.co/Qwen/Qwen2.5-Coder-32B-Instruct) model does not need special access, but the token can be used with other models requiring access.

Set the `HUGGINGFACEHUB_API_TOKEN` environment variable to the value of the Hugging Face token by executing the following command:
```bash
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

`host_ip` is not required to be set manually. It will be set in the `set_env.sh` script later.

For machines behind a firewall, set up the proxy environment variables:
```bash
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Use Case Setup

CodeGen will utilize the following GenAIComps services and associated tools. The tools and models listed in the table can be configured via environment variables in either the `set_env.sh` script or the `compose.yaml` file.

|Use Case Components | Tools | Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|LLM                  |   vLLM, TGI        | Qwen/Qwen2.5-Coder-32B-Instruct | OPEA Microservice |
|UI                   |              | NA                        | Gateway Service |

Set the necessary environment variables to set up the use case. To swap out models, modify `set_env.sh` before running it. For example, the environment variable `LLM_MODEL_ID` can be changed to another model by specifying the HuggingFace model card ID. 

To run the UI on a web browser on a laptop, modify `BACKEND_SERVICE_ENDPOINT` to use `localhost` or `127.0.0.1` instead of `host_ip` inside `set_env.sh` for the backend to properly receive data from the UI.

Run the `set_env.sh` script.
```bash
cd $WORKSPACE/GenAIExamples/CodeGen/docker_compose
source ./set_env.sh
```

## Deploy the Use Case

Navigate to the `docker compose` directory for this hardware platform.
```bash
cd $WORKSPACE/GenAIExamples/CodeGen/docker_compose/intel/hpu/gaudi
```

Run `docker compose` with the provided YAML file to start all the services mentioned above as containers. The vLLM or TGI service can be used for CodeGen.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
docker compose --profile codegen-gaudi-vllm up -d
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
docker compose --profile codegen-gaudi-tgi up -d
```
:::
::::

### Check Env Variables
After running `docker compose`, check for warning messages for environment variables that are **NOT** set. Address them if needed. 

    WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "https_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "http_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "https_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "http_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "http_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "https_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "http_proxy" variable is not set. Defaulting to a blank string.
    WARN[0000] The "https_proxy" variable is not set. Defaulting to a blank string.

Check if all the containers launched via `docker compose` are running i.e. each container's `STATUS` is `Up` and in some cases `Healthy`.

Run this command to see this info:
```bash
docker ps -a
```

Sample output: 
```bash
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED         STATUS                   PORTS                                                                                      NAMES
0040b340a392   opea/codegen-gradio-ui:latest                           "python codegen_ui_g…"   4 minutes ago   Up 3 minutes             0.0.0.0:5173->5173/tcp, [::]:5173->5173/tcp                                                codegen-gaudi-ui-server
3d2c7deacf5b   opea/codegen:latest                                     "python codegen.py"      4 minutes ago   Up 3 minutes             0.0.0.0:7778->7778/tcp, [::]:7778->7778/tcp                                                codegen-gaudi-backend-server
ad59907292fe   opea/dataprep:latest                                    "sh -c 'python $( [ …"   4 minutes ago   Up 4 minutes (healthy)   0.0.0.0:6007->5000/tcp, [::]:6007->5000/tcp                                                dataprep-redis-server
2cb4e0a6562e   opea/retriever:latest                                   "python opea_retriev…"   4 minutes ago   Up 4 minutes             0.0.0.0:7000->7000/tcp, [::]:7000->7000/tcp                                                retriever-redis
f787f774890b   opea/llm-textgen:latest                                 "bash entrypoint.sh"     4 minutes ago   Up About a minute        0.0.0.0:9000->9000/tcp, [::]:9000->9000/tcp                                                llm-codegen-vllm-server
5880b86091a5   opea/embedding:latest                                   "sh -c 'python $( [ …"   4 minutes ago   Up 4 minutes             0.0.0.0:6000->6000/tcp, [::]:6000->6000/tcp                                                tei-embedding-server
cd16e3c72f17   opea/llm-textgen:latest                                 "bash entrypoint.sh"     4 minutes ago   Up 4 minutes                                                                                                        llm-textgen-server
cd412bca7245   redis/redis-stack:7.2.0-v9                              "/entrypoint.sh"         4 minutes ago   Up 4 minutes             0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp, 0.0.0.0:8001->8001/tcp, [::]:8001->8001/tcp   redis-vector-db
8d4e77afc067   opea/vllm:latest                                        "python3 -m vllm.ent…"   4 minutes ago   Up 4 minutes (healthy)   0.0.0.0:8028->80/tcp, [::]:8028->80/tcp                                                    vllm-server
f7c1cb49b96b   ghcr.io/huggingface/text-embeddings-inference:cpu-1.5   "/bin/sh -c 'apt-get…"   4 minutes ago   Up 4 minutes (healthy)   0.0.0.0:8090->80/tcp, [::]:8090->80/tcp                                                    tei-embedding-serving

```

Each docker container's log can also be checked using:

```bash
docker logs <CONTAINER_ID OR CONTAINER_NAME>
```

## Validate Microservices

This section will guide through the various methods for interacting with the deployed microservices.

### vLLM or TGI Service

```bash
curl http://${host_ip}:8028/v1/chat/completions \
    -X POST \
    -H 'Content-Type: application/json' \
    -d '{"model": "Qwen/Qwen2.5-Coder-32B-Instruct", "messages": [{"role": "user", "content": "Implement a high-level API for a TODO list application. The API takes as input an operation request and updates the TODO list in place. If the request is invalid, raise an exception."}], "max_tokens":32}'

```

Here is sample output:
```bash
{"generated_text":"\n\nIO iflow diagram:\n\n!\[IO flow diagram(s)\]\(TodoList.iflow.svg\)\n\n### TDD Kata walkthrough\n\n1. Start with a user story. We will add story tests later. In this case, we'll choose a story about adding a TODO:\n    ```ruby\n    as a user,\n    i want to add a todo,\n    so that i can get a todo list.\n\n    conformance:\n    - a new todo is added to the list\n    - if the todo text is empty, raise an exception\n    ```\n\n1. Write the first test:\n    ```ruby\n    feature Testing the addition of a todo to the list\n\n    given a todo list empty list\n    when a user adds a todo\n    the todo should be added to the list\n\n    inputs:\n    when_values: [[\"A\"]]\n\n    output validations:\n    - todo_list contains { text:\"A\" }\n    ```\n\n1. Write the first step implementation in any programming language you like. In this case, we will choose Ruby:\n    ```ruby\n    def add_"}
```

### LLM Microservice

```bash
curl http://${host_ip}:9000/v1/chat/completions\
  -X POST \
  -H 'Content-Type: application/json' \
  -d '{"query":"Implement a high-level API for a TODO list application. The API takes as input an operation request and updates the TODO list in place. If the request is invalid, raise an exception.","max_tokens":256,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"stream":true}'
```

The output code is printed one character at a time. It is too long to show here but the last item will be
```bash
data: [DONE]
```

### Dataprep Microservice
The following is a template only. Replace the filename placeholders with desired files.

```bash
curl http://${host_ip}:6007/v1/dataprep/ingest \
-X POST \
-H "Content-Type: multipart/form-data" \
-F "files=@./file1.pdf" \
-F "files=@./file2.txt" \
-F "index_name=my_API_document"
```

### CodeGen Megaservice

Default:
```bash
curl http://${host_ip}:7778/v1/codegen -H "Content-Type: application/json" -d '{
     "messages": "Implement a high-level API for a TODO list application. The API takes as input an operation request and updates the TODO list in place. If the request is invalid, raise an exception."
     }'
```

The output code is printed one character at a time. It is too long to show here but the last item will be
```bash
data: [DONE]
```

The CodeGen Megaservice can also be utilized with RAG and Agents activated:
```bash
curl http://${host_ip}:7778/v1/codegen \
  -H "Content-Type: application/json" \
  -d '{"agents_flag": "True", "index_name": "my_API_document", "messages": "Implement a high-level API for a TODO list application. The API takes as input an operation request and updates the TODO list in place. If the request is invalid, raise an exception."}'
  ```

## Launch UI
### Gradio UI
To access the frontend, open the following URL in a web browser: http://${host_ip}:5173. By default, the UI runs on port 5173 internally. A different host port can be used to access the frontend by modifying the port mapping in the `compose.yaml` file as shown below:
```yaml
  codegen-gaudi-ui-server:
    image: ${REGISTRY:-opea}/codegen-gradio-ui:${TAG:-latest}
    ...
    ports:
      - "YOUR_HOST_PORT:5173" # Change YOUR_HOST_PORT to the desired port
```

After making this change, restart the containers for the change to take effect. 

## Stop the Services

Navigate to the `docker compose` directory for this hardware platform.
```bash
cd $WORKSPACE/GenAIExamples/CodeGen/docker_compose/intel/hpu/gaudi
```

To stop and remove all the containers, use the commands below:

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
docker compose --profile codegen-gaudi-vllm down
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
docker compose --profile codegen-gaudi-tgi down
```
:::
::::
