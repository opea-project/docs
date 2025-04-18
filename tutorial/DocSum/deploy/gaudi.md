# Single node on-prem deployment on Gaudi AI Accelerator

This section covers the single-node on-prem deployment of the DocSum example. It will show how to build a document summarization service using the `Intel/neural-chat-7b-v3-3` model deployed on Intel® Gaudi® AI Accelerators. To quickly learn about OPEA and set up the required hardware and software, follow the instructions in the [Getting Started](../../../getting-started/README.md) section.

## Overview

The OPEA GenAIComps microservices used to deploy a single node vLLM or TGI megaservice solution for DocSum are listed below:

1. ASR
2. LLM with vLLM or TGI

This solution is designed to demonstrate the use of the `Intel/neural-chat-7b-v3-3` model on the Intel® Gaudi® AI Accelerators to take a document (.txt,.doc,.pdf), audio, or video file as the input and generate a summary. The steps will involve setting up Docker containers, uploading documents, and generating summaries. Although multiple versionf of the UI can be deployed, this tutorial will focus solely on the Gradio UI because it can handle multimedia docuemnts, .doc, and .pdf files.

## Prerequisites

To run the UI on a web browser external to the host machine such as a laptop, the following port(s) need to be port forwarded when using SSH to log in to the host machine:
- 8888: DocSum megaservice port

This port is used for `BACKEND_SERVICE_ENDPOINT` defined in the `set_env.sh` for this example inside the `docker compose` folder. Specifically, for DocSum, append the following to the ssh command: 
```bash
-L 8888:localhost:8888
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

Set up a [HuggingFace](https://huggingface.co/) account and generate a [user access token](https://huggingface.co/docs/transformers.js/en/guides/private#step-1-generating-a-user-access-token). The [Intel/neural-chat-7b-v3-3](https://huggingface.co/Intel/neural-chat-7b-v3-3) model does not need special access, but the token can be used with other models requiring access.

Set the `HUGGINGFACEHUB_API_TOKEN` environment variable to the value of the Hugging Face token by executing the following command:
```bash
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

Set the `host_ip` environment variable to deploy the microservices on the endpoints enabled with ports:
```bash
export host_ip=$(hostname -I | awk '{print $1}')
```

## Use Case Setup

DocSum will utilize the following GenAIComps services and associated tools. The tools and models listed in the table can be configured via environment variables in either the `set_env.sh` script or the `compose.yaml` file.

|Use Case Components  | Tools        | Model                       | Service Type      |
|----------------     |--------------|-----------------------------|------------------ |
|LLM                  | vLLM or TGI  | Intel/neural-chat-7b-v3-3   | OPEA Microservice |
|ASR                  | Whisper      | openai/whisper-small        | OPEA Microservice |
|UI                   |              | NA                          | Gateway Service   |

Set the necessary environment variables to set up the use case. To swap out models, modify `set_env.sh` before running it. For example, the environment variable `LLM_MODEL_ID` can be changed to another model by specifying the HuggingFace model card ID. 

To run the UI on a web browser on a laptop, modify `BACKEND_SERVICE_ENDPOINT` to use `localhost` or `127.0.0.1` instead of `host_ip` inside `set_env.sh` for the backend to properly receive data from the UI.

Run the `set_env.sh` script.
```bash
cd $WORKSPACE/GenAIExamples/DocSum/docker_compose
source ./set_env.sh
```

## Deploy the Use Case

Navigate to the `docker compose` directory for this hardware platform.
```bash
cd $WORKSPACE/GenAIExamples/DocSum/docker_compose/intel/hpu/gaudi
```

Run `docker compose` with the provided YAML file to start all the services mentioned above as containers. The vLLM or TGI service can be used for DocSum.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
docker compose -f compose.yaml up -d
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
docker compose -f compose_tgi.yaml up -d
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

Check if all the containers launched via `docker compose` are running i.e. each container's `STATUS` is `Up` and `Healthy`.

Run this command to see this info:
```bash
docker ps -a
```

Sample output:
```bash
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS                   PORTS                                         NAMES
d02da5001212   opea/docsum-gradio-ui:latest   "python docsum_ui_gr…"   2 minutes ago   Up 19 seconds            0.0.0.0:5173->5173/tcp, [::]:5173->5173/tcp   docsum-gaudi-ui-server
43de0d8ee9dd   opea/docsum:latest             "python docsum.py"       2 minutes ago   Up 19 seconds            0.0.0.0:8888->8888/tcp, [::]:8888->8888/tcp   docsum-gaudi-backend-server
81f0e8d27f1f   opea/llm-docsum:latest         "bash entrypoint.sh"     2 minutes ago   Up 20 seconds            0.0.0.0:9000->9000/tcp, [::]:9000->9000/tcp   docsum-gaudi-llm-server
a4a9501fc4df   opea/whisper:latest            "python whisper_serv…"   3 minutes ago   Up 2 minutes             0.0.0.0:7066->7066/tcp, [::]:7066->7066/tcp   docsum-gaudi-whisper-server
951abf0ebb5a   opea/vllm:latest               "python3 -m vllm.ent…"   3 minutes ago   Up 2 minutes (healthy)   0.0.0.0:8008->80/tcp, [::]:8008->80/tcp       docsum-gaudi-vllm-service
```

Each docker container's log can also be checked using:
```bash
docker logs <CONTAINER_ID OR CONTAINER_NAME>
```

## Validate Microservices

This section will guide through the various methods for interacting with the deployed microservices.

### vLLM or TGI Service

During the initial startup, this service will take a few minutes to download the model files and complete the warm-up process. Once this is finished, the service will be ready for use.

Try the command below to check whether the LLM service is ready. It uses the name of the image to check the status.

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
# vLLM service
docker logs docsum-gaudi-vllm-service 2>&1 | grep complete
# If the service is ready, you will get the response like below.
INFO:     Application startup complete.
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
# TGI service
docker logs docsum-gaudi-tgi-server | grep Connected
# If the service is ready, you will get the response like below.
2024-09-03T02:47:53.402023Z  INFO text_generation_router::server: router/src/server.rs:2311: Connected
```
:::
::::

Then try the `cURL` command to verify the vLLM or TGI service: 
```bash
curl http://${host_ip}:8008/v1/chat/completions \
  -X POST \
  -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":17, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

Sample output:
```bash
{"generated_text":"\nDeep learning is a sub-discipline of machine learning. Machine learning is"}

```
### LLM Microservice

```bash
curl http://${host_ip}:9000/v1/docsum \
  -X POST \
  -d '{"query":"Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."}' \
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

Expected output:
```bash
 {"asr_result":"you"}
```

### DocSum Megaservice

Documents (.txt, .doc, .pdf), audio, and video can be uploaded to get a summary of the content. For each type of document, there are different input formats.

::::::{tab-set}
:::::{tab-item} Text
:sync: Text

JSON input:
```bash
curl -X POST http://${host_ip}:8888/v1/docsum \
     -H "Content-Type: application/json" \
     -d '{"type": "text", "messages": "Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5."}'
```

Form input with English mode (default):
```bash
curl http://${host_ip}:8888/v1/docsum \
    -H "Content-Type: multipart/form-data" \
    -F "type=text" \
    -F "messages=Text Embeddings Inference (TEI) is a toolkit for deploying and serving open source text embeddings and sequence classification models. TEI enables high-performance extraction for the most popular models, including FlagEmbedding, Ember, GTE and E5." \
    -F "max_tokens=32" \
    -F "language=en" \
    -F "stream=true"
```

Form input with Chinese mode:
```bash
curl http://${host_ip}:8888/v1/docsum \
    -H "Content-Type: multipart/form-data" \
    -F "type=text" \
    -F "messages=2024年9月26日，北京——今日，英特尔正式发布英特尔® 至强® 6性能核处理器（代号Granite Rapids），为AI、数据分析、科学计算等计算密集型业务提供卓越性能。" \
    -F "max_tokens=32" \
    -F "language=zh" \
    -F "stream=true"
```

Uploading a file:
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

Audio uploads are not supported through *curl* commands, so use the UI to upload it. It is possible to pass base64 encoded strings of the audio file:

JSON input:
```bash
curl -X POST http://${host_ip}:8888/v1/docsum \
   -H "Content-Type: application/json" \
   -d '{"type": "audio", "messages": "UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA"}'
```

Form input:
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

Video uploads are not supported through *curl* commands, so use the UI to upload it. It is possible to pass base64 strings of the video file as the value for the message parameter:

JSON input:
```bash
curl -X POST http://${host_ip}:8888/v1/docsum \
   -H "Content-Type: application/json" \
   -d '{"type": "video", "messages": "convert your video to base64 data type"}'
```

Form input:
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

#### Megaservice with Long Context

When performing summarization with long contexts - content longer than the model's context limit - different summarization strategies can be used such as *auto*, *stuff*, *truncate*, *map_reduce*, or *refine*. The best strategy is determined from various factors including model context size limits and number of input tokens.

The following parameters can be adjusted to work with long context:
- "summary_type": can be "auto", "stuff", "truncate", "map_reduce", "refine", default is "auto"
- "chunk_size": max token length for each chunk. Set to be different default value according to "summary_type".
- "chunk_overlap": overlap token length between each chunk, default is 0.1*chunk_size

Select the "summary_type" of interest to see how to run with it.

::::::{tab-set}
:::::{tab-item} auto
:sync: auto

"summary_type" is set to be "auto" by default, in this mode the input token length is checked. If it exceeds `MAX_INPUT_TOKENS`, `summary_type` will automatically be set to `refine` mode. Otherwise, it will be set to `stuff` mode.

```bash
curl http://${host_ip}:8888/v1/docsum \
  -H "Content-Type: multipart/form-data" \
  -F "type=text" \
  -F "messages=" \
  -F "max_tokens=32" \
  -F "files=@/path to your file (.txt, .docx, .pdf)" \
  -F "language=en" \
  -F "summary_type=auto"
```

:::::

:::::{tab-item} stuff
:sync: stuff

In this mode the LLM microservice generates a summary based on the entire input text. In this case, set `MAX_INPUT_TOKENS` and `MAX_TOTAL_TOKENS` according to the model and device memory. Otherwise, it may exceed the LLM context limit and raise errors when provided a longer context.

```bash
curl http://${host_ip}:8888/v1/docsum \
  -H "Content-Type: multipart/form-data" \
  -F "type=text" \
  -F "messages=" \
  -F "max_tokens=32" \
  -F "files=@/path to your file (.txt, .docx, .pdf)" \
  -F "language=en" \
  -F "summary_type=stuff"
```

:::::

:::::{tab-item} truncate
:sync: truncate

Truncate mode will truncate the input text and keep only the first chunk, whose length is equal to `min(MAX_TOTAL_TOKENS - input.max_tokens - 50, MAX_INPUT_TOKENS)`.

```bash
curl http://${host_ip}:8888/v1/docsum \
  -H "Content-Type: multipart/form-data" \
  -F "type=text" \
  -F "messages=" \
  -F "max_tokens=32" \
  -F "files=@/path to your file (.txt, .docx, .pdf)" \
  -F "language=en" \
  -F "summary_type=truncate"
```

:::::

:::::{tab-item} map_reduce
:sync: map_reduce

Map_reduce mode will split the inputs into multiple chunks, map each document to an individual summary, and consolidate all summaries into a single global summary. `stream=True` is not allowed here.

In this mode, `chunk_size` is set to `min(MAX_TOTAL_TOKENS - input.max_tokens - 50, MAX_INPUT_TOKENS)`.

```bash
curl http://${host_ip}:8888/v1/docsum \
  -H "Content-Type: multipart/form-data" \
  -F "type=text" \
  -F "messages=" \
  -F "max_tokens=32" \
  -F "files=@/path to your file (.txt, .docx, .pdf)" \
  -F "language=en" \
  -F "summary_type=map_reduce"
```

:::::

:::::{tab-item} refine
:sync: refine

Refine mode will split the inputs into multiple chunks, generate a summary for the first one, combine it with the second summary, and repeats with all remaining chunks to get the final summary.

In this mode, default `chunk_size` is set to `min(MAX_TOTAL_TOKENS - 2 * input.max_tokens - 128, MAX_INPUT_TOKENS)`.

```bash
curl http://${host_ip}:8888/v1/docsum \
  -H "Content-Type: multipart/form-data" \
  -F "type=text" \
  -F "messages=" \
  -F "max_tokens=32" \
  -F "files=@/path to your file (.txt, .docx, .pdf)" \
  -F "language=en" \
  -F "summary_type=refine"
```

:::::

::::::

## Launch UI

The Gradio UI is recommended because it can work with multimedia documents, .doc, and .pdf files.

### Gradio UI
To access the frontend, open the following URL in a web browser: http://${host_ip}:5173. By default, the UI runs on port 5173 internally. A different host port can be used to access the frontend by modifying the `FRONTEND_SERVICE_PORT` environment variable. For reference, the port mapping in the `compose.yaml` file is shown below:
```yaml
  docsum-gradio-ui:
    image: ${REGISTRY:-opea}/docsum-gradio-ui:${TAG:-latest}
    ...
    ports:
    - "${FRONTEND_SERVICE_PORT:-5173}:5173"
```

After making this change, rebuild and restart the containers for the change to take effect. 

## Stop the Services

Navigate to the `docker compose` directory for this hardware platform.
```bash
cd $WORKSPACE/GenAIExamples/DocSum/docker_compose/intel/hpu/gaudi
```

To stop and remove all the containers, use the command below:

::::{tab-set}
:::{tab-item} vllm
:sync: vllm

```bash
docker compose -f compose.yaml down
```
:::
:::{tab-item} TGI
:sync: TGI

```bash
docker compose -f compose_tgi.yaml down
```
:::
::::
