# Single node on-prem deployment with TGI on Intel® Xeon® Scalable processor


This deployment section covers single-node on-prem deployment of the DocSum
example with OPEA comps to deploy using the TGI service. We will be showcasing how
to build an e2e DocSum solution with the Intel/neural-chat-7b-v3-3 model, deployed on 
Intel® Xeon® Scalable processors. To quickly learn about OPEA in just 5 minutes and set
 up the required hardware and software, please follow the instructions in the 
 [Getting Started](https://opea-project.github.io/latest/getting-started/README.html) 
section. 

## Overview

The DocSum use case uses  LLM and ASR microservices. In this tutorial, we 
will walk through the steps on how to enable it from OPEA GenAIComps to deploy on 
a single node. 

The solution is aimed to show how to use the Intel/neural-chat-7b-v3-3 model on the 
Intel® Xeon® Scalable processors. We will go through how to set up docker containers to start 
the microservice and megaservice. The solution will then take a document(.txt,.doc,.pdf), audio or 
video file as the input and generate a summary. It is deployed with a UI with 3 modes to 
choose from:

1. Gradio-Based UI
2. Svelte-Based UI
3. React-Based UI

If you need to work with multimedia documents, .doc, or .pdf files, it is suggested that you use Gradio UI.

Below is the list of content we will be covering in this tutorial:

1. Prerequisites
2. Prepare (Building / Pulling) Docker images
3. Use case setup
4. Deploy the use case
5. Interacting with DocSum deployment

## Prerequisites

The first step is to clone the GenAIExamples and GenAIComps. GenAIComps are
fundamental necessary components used to build examples you find in
GenAIExamples and deploy them as microservices. Also, set the `TAG` 
environment variable with the version. 

```bash
git clone https://github.com/opea-project/GenAIComps.git
git clone https://github.com/opea-project/GenAIExamples.git
export TAG=1.2
```

The example requires you to set the `host_ip` to deploy the microservices on the endpoint enabled with ports. Set the host_ip env variable.

```
export host_ip=$(hostname -I | awk '{print $1}')
```

Make sure to set up Proxies if you are behind a firewall.
```
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Prepare (Building / Pulling) Docker images

This step will involve building/pulling relevant docker
images with a step-by-step process along with a sanity check at the end. For
DocSum, the following docker images will be needed: llm-docsum and whisper. 
Additionally, you will need to build docker images for the 
DocSum megaservice, and UI (Svelte/React UI is optional). In total,
there are **4 required docker images** and two optional docker images.

### Build/Pull Microservice image

::::::{tab-set}

:::::{tab-item} Pull
:sync: Pull

If you decide to pull the docker containers and not build them locally,
you can proceed to the next step where all the necessary containers will
be pulled in from the docker hub.

:::::
:::::{tab-item} Build
:sync: Build

From within the `GenAIComps` folder, check out the release tag.
```
cd GenAIComps
git checkout tags/v${TAG}
```

#### Build Whisper Service

```bash
docker build -t opea/whisper:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/asr/src/integrations/dependency/whisper/Dockerfile .
```

### Build Mega Service images

The Megaservice is a pipeline that channels data through different
microservices, each performing varied tasks. The LLM, whisper microservice, and flow of data are defined in the `docsum.py` file. You can also add or 
remove microservices and customize the megaservice to suit your needs.

Build the megaservice image for this use case.

```bash
cd ..
cd GenAIExamples
git checkout tags/v${TAG}
cd DocSum
```

```bash
docker build -t opea/docsum:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile .
cd ../..
```

### Build the UI Image

You can build 3 modes of UI

*Gradio UI*

```bash
cd GenAIExamples/DocSum/ui
docker build -t opea/docsum-gradio-ui:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f docker/Dockerfile.gradio .
cd ../../..
```

*Svelte UI (Optional)*

```bash
cd GenAIExamples/DocSum/ui
docker build -t opea/docsum-ui:${TAG} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f docker/Dockerfile .
cd ../../..
```

*React UI (Optional)* 
If you want a React-based frontend.

```bash
export BACKEND_SERVICE_ENDPOINT="http://${host_ip}:8888/v1/docsum"
docker build -t opea/docsum-react-ui:${TAG} --build-arg BACKEND_SERVICE_ENDPOINT=$BACKEND_SERVICE_ENDPOINT --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy  -f ./docker/Dockerfile.react .
cd ../../..
```

### Sanity Check
Check if you have the following set of docker images by running the command `docker images` before moving on to the next step. 
The tags are based on what you set the environment variable `TAG` to. 

* `opea/whisper:${TAG}`
* `opea/docsum:${TAG}`
* `opea/docsum-gradio-ui:${TAG}`
* `opea/docsum-ui:${TAG}` (optional)
* `opea/docsum-react-ui:${TAG}` (optional)

:::::
::::::

## Use Case Setup

The use case will use the following combination of GenAIComps and tools.

|Use Case Components  | Tools        | Model                      | Service Type      |
|----------------     |--------------|----------------------------|------------------ |
|LLM                  |   TGI        | Intel/neural-chat-7b-v3-3  | OPEA Microservice |
|ASR                  |   Whisper    | openai/whisper-small       | OPEA Microservice |
|UI                   |              | NA                         | Gateway Service   |


Tools and models mentioned in the table are configurable either through the
environment variables or the `compose.yaml` file.

Set the necessary environment variables to set up the use case by running the `set_env.sh` script.
Here is where the environment variable `LLM_MODEL_ID` is set, and you can change it to another model 
by specifying the HuggingFace model card ID.

```bash
cd GenAIExamples/DocSum/docker_compose
source ./set_env.sh
cd ../../..
```

## Deploy the Use Case

In this tutorial, we will be deploying via docker compose with the provided
YAML file.  The docker compose instructions should start all the
above-mentioned services as containers.

```bash
cd GenAIExamples/DocSum/docker_compose/intel/cpu/xeon
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

The DocSum example starts 4 docker containers. Check that these docker
containers are all running, i.e., all the containers  `STATUS` are  `Up`.
You can do this with the `docker ps -a` command.

```
CONTAINER ID   IMAGE                                                           COMMAND                  CREATED             STATUS                       PORTS                                       NAMES
8ec82528bcbb   opea/docsum-gradio-ui:latest                                    "python docsum_ui_gr…"   About an hour ago   Up About an hour             0.0.0.0:5173->5173/tcp, :::5173->5173/tcp   docsum-xeon-ui-server
e22344ed80d5   opea/docsum:latest                                              "python docsum.py"       About an hour ago   Up About an hour             0.0.0.0:8888->8888/tcp, :::8888->8888/tcp   docsum-xeon-backend-server
bbb3c05a2878   opea/llm-docsum:latest                                          "bash entrypoint.sh"     About an hour ago   Up About an hour             0.0.0.0:9000->9000/tcp, :::9000->9000/tcp   llm-docsum-server
d20a8896d2a0   ghcr.io/huggingface/text-generation-inference:2.4.0-intel-cpu   "text-generation-lau…"   About an hour ago   Up About an hour (healthy)   0.0.0.0:8008->80/tcp, :::8008->80/tcp       tgi-server
8213029b6b26   opea/whisper:latest                                             "python whisper_serv…"   About an hour ago   Up About an hour             0.0.0.0:7066->7066/tcp, :::7066->7066/tcp   whisper-server
```

## Interacting with DocSum for Deployment

This section will walk you through the different ways to interact with
the microservices deployed. After a couple of minutes, rerun `docker ps -a` 
to ensure all the docker containers are still up and running. Then proceed 
to validate each microservice and megaservice. 

### TGI Service

```bash
curl http://${host_ip}:8008/generate \
 -X POST \
  -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":17, "do_sample": true}}' \
 -H 'Content-Type: application/json'
```

Here is the output:

```
{"generated_text":"\nDeep learning is a sub-discipline of machine learning. Machine learning is"}

```
### LLM Microservice

```bash
curl http://${host_ip}:9000/v1/docsum \
 -X POST \
  -d '{"query":"Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE, and E5."}' \
 -H 'Content-Type: application/json'
```

The output is the summary of the input given to this microservice.

### Whisper Microservice

```bash
 curl http://${host_ip}:7066/v1/asr \
 -X POST \
     -d '{"audio":"UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA"}' \
 -H 'Content-Type: application/json'
```

Here is the output:
```
 {"asr_result":"you"}
```

### MegaService

You can upload documents (.txt, .doc, .pdf), audio, and video to get a summary of the content.

::::::{tab-set}
:::::{tab-item} Text
:sync: Text

The megaservice accepts input files in txt, pdf, doc format, or plain text in the message parameter.
```bash
curl http://${host_ip}:8888/v1/docsum \
 -H "Content-Type: multipart/form-data" \
    -F "type=text" \
 -F "messages=Text Embeddings Inference (TEI) is a toolkit for deploying and serving open-source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE, and E5." \
    -F "max_tokens=32" \
 -F "language=en" \
    -F "stream=true"
```

The output will be the summarization of the text content. We can also upload files and modify the other parametes such as the streaming mode and language.

```bash
curl http://${host_ip}:8888/v1/docsum \
 -H "Content-Type: multipart/form-data" \
   -F "type=text" \
 -F "messages=" \
   -F "files=@/path to your file (.txt, .docx, .pdf)" \
 -F "max_tokens=32" \
   -F "language=en" \
 -F "stream=true"
```
:::::

:::::{tab-item} Audio
:sync: Audio

Audio uploads are not supported through curl command, use the UI to upload it. You can pass base64 string of the audio file as follows :

```bash
curl http://${host_ip}:8888/v1/docsum \
 -H "Content-Type: multipart/form-data" \
   -F "type=audio" \
 -F "messages=UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA" \
   -F "max_tokens=32" \
 -F "language=en" \
   -F "stream=true"
```
:::::

:::::{tab-item} Video
:sync: Video

Video uploads are not supported through curl command, use the UI to upload it. You can pass base64 string of the video file as the value for the message parameter as shown here :

```bash
curl http://${host_ip}:8888/v1/docsum \
 -H "Content-Type: multipart/form-data" \
   -F "type=video" \
 -F "messages=convert your video to base64 data type" \
   -F "max_tokens=32" \
 -F "language=en" \
   -F "stream=true"

```
:::::

::::::

When dealing with longer context of the content to be summarized, we can use different summarization strategies such as auto, stuff, truncate, map_reduce, or refine. Depending on various factors like models context size and input tokens we can select the stratergy that best fits.

1. Auto : In this mode, we will check input token length, if it exceeds MAX_INPUT_TOKENS, summary_type will automatically be set to refine mode, otherwise will be set to stuff mode.

2. Stuff : In this mode, LLM generates a summary based on a complete input text. In this case please carefully set MAX_INPUT_TOKENS and MAX_TOTAL_TOKENS according to your model and device memory, otherwise, it may exceed LLM context limit and raise an error when meeting long context.

3. Truncate : Truncate mode will truncate the input text and keep only the first chunk, whose length is equal to min(MAX_TOTAL_TOKENS - input.max_tokens - 50, MAX_INPUT_TOKENS).

4. Map_reduce : Map_reduce mode will split the inputs into multiple chunks, map each document to an individual summary, then consolidate those summaries into a single global summary. stream=True is not allowed here. In this mode, default chunk_size is set to be min(MAX_TOTAL_TOKENS - input.max_tokens - 50, MAX_INPUT_TOKENS).

5. Refine : Refine mode will split the inputs into multiple chunks, generate a summary for the first one, then combine it with the second, and loop over every remaining chunk to get the final summary. In this mode, default chunk_size is set to be min(MAX_TOTAL_TOKENS - 2 * input.max_tokens - 128, MAX_INPUT_TOKENS).

We can define the summary_type by providing one of the 5 values discussed above as the value for the summary_type variable as shown below:
```bash
curl http://${host_ip}:8888/v1/docsum \
 -H "Content-Type: multipart/form-data" \
   -F "type=text" \
 -F "messages=" \
   -F "max_tokens=32" \
 -F "files=@/path to your file (.txt, .docx, .pdf)" \
   -F "language=en" \
 -F "summary_type=One of the above 5 types"
```

## Launch UI
### Gradio UI
To access the frontend, open the following URL in your browser: http://{host_ip}:5173. By default, the UI runs on port 5173 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the `compose.yaml` file as shown below:
```bash
  docsum-xeon-ui-server:
  image: ${REGISTRY:-opea}/docsum-ui:${TAG:-latest}
  ...
  ports:
  - "5173:5173"
```
### Svelte UI (Optional)
To access the Svelte-based frontend, modify the UI service in the `compose.yaml` file. Replace `docsum-gradio-ui` service with the `docsum-ui` service as per the config below: 
```bash
  docsum-ui:
    image: ${REGISTRY:-opea}/docsum-ui:${TAG:-latest}
    container_name: docsum-xeon-ui-server
    depends_on:
    - docsum-xeon-backend-server
    ports:
    - "5173:5173"
    environment:
    - no_proxy=${no_proxy}
    - https_proxy=${https_proxy}
    - http_proxy=${http_proxy}
    - BACKEND_SERVICE_ENDPOINT=${BACKEND_SERVICE_ENDPOINT}
    - DOC_BASE_URL=${BACKEND_SERVICE_ENDPOINT}
    ipc: host
    restart: always
```
### React-Based UI (Optional)
To access the React-based frontend, modify the UI service in the `compose.yaml` file. Replace `docsum-gradio-ui` service with the `docsum-react-ui` service as per the config below:
```bash
  docsum-xeon-react-ui-server:
    image: ${REGISTRY:-opea}/docsum-react-ui:${TAG:-latest}
    container_name: docsum-xeon-react-ui-server
    depends_on:
    - docsum-xeon-backend-server
    ports:
    - "5174:80"
    environment:
    - no_proxy=${no_proxy}
    - https_proxy=${https_proxy}
    - http_proxy=${http_proxy}
    ipc: host
    restart: always
```


Once the services are up, open the following URL in your browser: http://{host_ip}:5174. By default, the UI runs on port 80 internally. If you prefer to use a different host port to access the frontend, you can modify the port mapping in the `compose.yaml` file as shown below:
```bash
  docsum-xeon-react-ui-server:
    image: ${REGISTRY:-opea}/docsum-react-ui:${TAG:-latest}
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

Assuming you are still in this directory `GenAIExamples/DocSum/docker_compose/intel/cpu/xeon`,
run the following command to check the logs:
```bash
docker compose -f compose.yaml logs
```

View the docker input parameters in  `./DocSum/docker_compose/intel/cpu/xeon/compose.yaml`

```yaml
    tgi-server:
      image: ghcr.io/huggingface/text-generation-inference:2.4.0-intel-cpu
      container_name: tgi-server
      ports:
        - ${LLM_ENDPOINT_PORT:-8008}:80
      environment:
        no_proxy: ${no_proxy}
        http_proxy: ${http_proxy}
        https_proxy: ${https_proxy}
        TGI_LLM_ENDPOINT: ${TGI_LLM_ENDPOINT}
        HUGGINGFACEHUB_API_TOKEN: ${HUGGINGFACEHUB_API_TOKEN}
        host_ip: ${host_ip}
        LLM_ENDPOINT_PORT: ${LLM_ENDPOINT_PORT}
      healthcheck:
        test: ["CMD-SHELL", "curl -f http://${host_ip}:${LLM_ENDPOINT_PORT}/health || exit 1"]
        interval: 10s
        timeout: 10s
        retries: 100
      volumes:
        - "./data:/data"
      shm_size: 1g
      command: --model-id ${LLM_MODEL_ID} --cuda-graphs 0  --max-input-length ${MAX_INPUT_TOKENS} --max-total-tokens ${MAX_TOTAL_TOKENS}
```

The input `--model-id` is  `${LLM_MODEL_ID}`. Ensure the environment variable `LLM_MODEL_ID` 
is set and spelled correctly. Check spelling. Whenever this is changed, restart the containers to use 
the newly selected model.


## Stop the services

Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:
```
docker compose down
```

