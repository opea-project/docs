# Single node on-prem deployment with TGI on Gaudi AI Accelerator

This deployment section covers single-node on-prem deployment of the CodeGen
example with OPEA comps to deploy using the TGI service. We will be showcasing how
to build an e2e CodeGen solution with the CodeLlama-7b-hf model, deployed on Intel® 
Tiber™ AI Cloud ([ITAC](https://www.intel.com/content/www/us/en/developer/tools/tiber/ai-cloud.html)). 
To quickly learn about OPEA in just 5 minutes and set up the required hardware and software, 
please follow the instructions in the [Getting Started](https://opea-project.github.io/latest/getting-started/README.html) 
section. If you do not have an ITAC instance or the hardware is not supported in the ITAC yet, you can still run this on-prem. 

## Overview

The CodeGen use case uses a single microservice called LLM. In this tutorial, we 
will walk through the steps on how to enable it from OPEA GenAIComps to deploy on 
a single node TGI megaservice solution. 

The solution is aimed to show how to use the CodeLlama-7b-hf model on the Intel® 
Gaudi® AI Accelerator. We will go through how to setup docker containers to start 
the microservice and megaservice. The solution will then take text input as the 
prompt and generate code accordingly. It is deployed with a UI with 2 modes to 
choose from:

1. Svelte-Based UI
2. React-Based UI

The React-based UI is optional, but this feature is supported in this example if you
are interested in using it.

Below is the list of content we will be covering in this tutorial:

1. Prerequisites
2. Prepare (Building / Pulling) Docker images
3. Use case setup
4. Deploy the use case
5. Interacting with CodeGen deployment

## Prerequisites

The first step is to clone the GenAIExamples and GenAIComps. GenAIComps are
fundamental necessary components used to build examples you find in
GenAIExamples and deploy them as microservices. Also set the `TAG` 
environment variable with the version. 

```bash
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
export TAG=1.1
```

The examples utilize model weights from HuggingFace and langchain.

Setup your [HuggingFace](https://huggingface.co/) account and generate
[user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token).

Setup the HuggingFace token
```
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

Additionally, if you plan to use the default model CodeLlama-7b-hf, you will 
need to [request access](https://huggingface.co/meta-llama/CodeLlama-7b-hf) from HuggingFace.

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
CodeGen, the following docker images will be needed: LLM with TGI. 
Additionally, you will need to build docker images for the 
CodeGen megaservice, and UI (React UI is optional). In total,
there are **3 required docker images** and an optional docker image.

### Build/Pull Microservice image

::::::{tab-set}

:::::{tab-item} Pull
:sync: Pull

If you decide to pull the docker containers and not build them locally,
you can proceed to the next step where all the necessary containers will
be pulled in from dockerhub.

:::::
:::::{tab-item} Build
:sync: Build

From within the `GenAIComps` folder, checkout the release tag.
```
cd GenAIComps
git checkout tags/v${TAG}
```

#### Build LLM Image

```bash
docker build --no-cache -t opea/llm-tgi:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/llms/text-generation/tgi/Dockerfile .
```

### Build Mega Service images

The Megaservice is a pipeline that channels data through different
microservices, each performing varied tasks. The LLM microservice and 
flow of data are defined in the `codegen.py` file. You can also add or 
remove microservices and customize the megaservice to suit your needs.

Build the megaservice image for this use case

```bash
cd ..
cd GenAIExamples
git checkout tags/v${TAG}
cd CodeGen
```

```bash
docker build --no-cache -t opea/codegen:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile .
cd ../..
```

### Build the UI Image

You can build 2 modes of UI

*Svelte UI*

```bash
cd GenAIExamples/CodeGen/ui/
docker build --no-cache -t opea/codegen-ui:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile .
cd ../../..
```

*React UI (Optional)* 
If you want a React-based frontend.

```bash
cd GenAIExamples/CodeGen/ui/
docker build --no-cache -t opea/codegen-react-ui:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f ./docker/Dockerfile.react .
cd ../../..
```

### Sanity Check
Check if you have the following set of docker images by running the command `docker images` before moving on to the next step. 
The tags are based on what you set the environment variable `TAG` to. 

* `opea/llm-tgi:${TAG}`
* `opea/codegen:${TAG}`
* `opea/codegen-ui:${TAG}`
* `opea/codegen-react-ui:${TAG}` (optional)

:::::
::::::

## Use Case Setup

The use case will use the following combination of GenAIComps and tools

|Use Case Components | Tools | Model     | Service Type |
|----------------     |--------------|-----------------------------|-------|
|LLM                  |   TGI        | meta-llama/CodeLlama-7b-hf | OPEA Microservice |
|UI                   |              | NA                        | Gateway Service |

Tools and models mentioned in the table are configurable either through the
environment variables or `compose.yaml` file.

Set the necessary environment variables to setup the use case by running the `set_env.sh` script.
Here is where the environment variable `LLM_MODEL_ID` is set, and you can change it to another model 
by specifying the HuggingFace model card ID.

```bash
cd GenAIExamples/CodeGen/docker_compose/
source ./set_env.sh
cd ../../..
```

## Deploy the Use Case

In this tutorial, we will be deploying via docker compose with the provided
YAML file.  The docker compose instructions should be starting all the
above mentioned services as containers.

```bash
cd GenAIExamples/CodeGen/docker_compose/intel/hpu/gaudi
docker compose up -d
```


### Checks to Ensure the Services are Running
#### Check Startup and Env Variables
Check the startup log by running `docker compose logs` to ensure there are no errors.
The warning messages print out the variables if they are **NOT** set.

Here are some sample messages if proxy environment variables are not set:

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

#### Check the Container Status
Check if all the containers launched via docker compose have started.

The CodeGen example starts 4 docker containers. Check that these docker
containers are all running, i.e, all the containers  `STATUS`  are  `Up`.
You can do this with the `docker ps -a` command.

```
CONTAINER ID   IMAGE                                                   COMMAND                  CREATED              STATUS              PORTS                                       NAMES
bbd235074c3d   opea/codegen-ui:${TAG}                                  "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:5173->5173/tcp, :::5173->5173/tcp   codegen-gaudi-ui-server
8d3872ca66fa   opea/codegen:${TAG}                                     "python codegen.py"      About a minute ago   Up About a minute   0.0.0.0:7778->7778/tcp, :::7778->7778/tcp   codegen-gaudi-backend-server
b9fc39f51cdb   opea/llm-tgi:${TAG}                                     "bash entrypoint.sh"     About a minute ago   Up About a minute   0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   llm-tgi-gaudi-server
39994e007f15   ghcr.io/huggingface/tgi-gaudi:2.0.1                     "text-generation-lau…"   About a minute ago   Up About a minute   0.0.0.0:8028->80/tcp, :::8028->80/tcp       tgi-gaudi-server
```

## Interacting with CodeGen for Deployment

This section will walk you through the different ways to interact with
the microservices deployed. After a couple minutes, rerun `docker ps -a` 
to ensure all the docker containers are still up and running. Then proceed 
to validate each microservice and megaservice. 

### TGI Service

```bash
curl http://${host_ip}:8028/generate \
  -X POST \
  -d '{"inputs":"Implement a high-level API for a TODO list application. The API takes as input an operation request and updates the TODO list in place. If the request is invalid, raise an exception.","parameters":{"max_new_tokens":256, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

Here is the output:

```
{"generated_text":"\n\nIO iflow diagram:\n\n!\[IO flow diagram(s)\]\(TodoList.iflow.svg\)\n\n### TDD Kata walkthrough\n\n1. Start with a user story. We will add story tests later. In this case, we'll choose a story about adding a TODO:\n    ```ruby\n    as a user,\n    i want to add a todo,\n    so that i can get a todo list.\n\n    conformance:\n    - a new todo is added to the list\n    - if the todo text is empty, raise an exception\n    ```\n\n1. Write the first test:\n    ```ruby\n    feature Testing the addition of a todo to the list\n\n    given a todo list empty list\n    when a user adds a todo\n    the todo should be added to the list\n\n    inputs:\n    when_values: [[\"A\"]]\n\n    output validations:\n    - todo_list contains { text:\"A\" }\n    ```\n\n1. Write the first step implementation in any programming language you like. In this case, we will choose Ruby:\n    ```ruby\n    def add_"}
```

### LLM Microservice

```bash
curl http://${host_ip}:9000/v1/chat/completions\
  -X POST \
  -d '{"query":"Implement a high-level API for a TODO list application. The API takes as input an operation request and updates the TODO list in place. If the request is invalid, raise an exception.","max_tokens":256,"top_k":10,"top_p":0.95,"typical_p":0.95,"temperature":0.01,"repetition_penalty":1.03,"streaming":true}' \
  -H 'Content-Type: application/json'
```

The output is given one character at a time. It is too long to show 
here but the last item will be
```
data: [DONE]
```

### MegaService

```bash
curl http://${host_ip}:7778/v1/codegen -H "Content-Type: application/json" -d '{
     "messages": "Implement a high-level API for a TODO list application. The API takes as input an operation request and updates the TODO list in place. If the request is invalid, raise an exception."
     }'
```

The output is given one character at a time. It is too long to show 
here but the last item will be
```
data: [DONE]
```

## Launch UI
### Svelte UI
To access the frontend, open the following URL in your browser: http://{host_ip}:5173. By default, the UI runs on port 5173 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the `compose.yaml` file as shown below:
```bash
  codegen-gaudi-ui-server:
    image: ${REGISTRY:-opea}/codegen-ui:${TAG:-latest}
    ...
    ports:
      - "5173:5173"
```

### React-Based UI (Optional)
To access the React-based frontend, modify the UI service in the `compose.yaml` file. Replace `codegen-gaudi-ui-server` service with the codegen-gaudi-react-ui-server service as per the config below:
```bash
codegen-gaudi-react-ui-server:
  image: ${REGISTRY:-opea}/codegen-react-ui:${TAG:-latest}
  container_name: codegen-gaudi-react-ui-server
  environment:
    - no_proxy=${no_proxy}
    - https_proxy=${https_proxy}
    - http_proxy=${http_proxy}
    - APP_CODE_GEN_URL=${BACKEND_SERVICE_ENDPOINT}
  depends_on:
    - codegen-gaudi-backend-server
  ports:
    - "5174:80"
  ipc: host
  restart: always
```
Once the services are up, open the following URL in your browser: http://{host_ip}:5174. By default, the UI runs on port 80 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the `compose.yaml` file as shown below:
```bash
  codegen-gaudi-react-ui-server:
    image: ${REGISTRY:-opea}/codegen-react-ui:${TAG:-latest}
    ...
    ports:
      - "80:80"
```

## Check Docker Container Logs

You can check the log of a container by running this command:

```bash
docker logs <CONTAINER ID> -t
```

You can also check the overall logs with the following command, where the
`compose.yaml` is the megaservice docker-compose configuration file.

Assumming you are still in this directory `GenAIExamples/CodeGen/docker_compose/intel/hpu/gaudi`,
run the following command to check the logs:
```bash
docker compose -f compose.yaml logs
```

View the docker input parameters in  `./CodeGen/docker_compose/intel/hpu/gaudi/compose.yaml`

```yaml
  tgi-service:
    image: ghcr.io/huggingface/tgi-gaudi:2.0.1
    container_name: tgi-gaudi-server
    ports:
      - "8028:80"
    volumes:
      - "./data:/data"
    environment:
      no_proxy: ${no_proxy}
      http_proxy: ${http_proxy}
      https_proxy: ${https_proxy}
      HABANA_VISIBLE_DEVICES: all
      OMPI_MCA_btl_vader_single_copy_mechanism: none
      HF_TOKEN: ${HUGGINGFACEHUB_API_TOKEN}
    runtime: habana
    cap_add:
      - SYS_NICE
    ipc: host
    command: --model-id ${LLM_MODEL_ID} --max-input-length 1024 --max-total-tokens 2048
```

The input `--model-id` is  `${LLM_MODEL_ID}`. Ensure the environment variable `LLM_MODEL_ID` 
is set and spelled correctly. Check spelling. Whenever this is changed, restart the containers to use 
the newly selected model.


## Stop the services

Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:
```
docker compose down
```
