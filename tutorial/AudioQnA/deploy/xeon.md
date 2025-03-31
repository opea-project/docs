# Single node on-prem deployment with TGI on Xeon Scalable processors

This deployment section covers single-node on-prem deployment of the AudioQnA example with OPEA comps to deploy using TGI service. The solution demonstrates building a voice chat service using the TGI deployed on Intel® Xeon® Scalable processors. To quickly learn about OPEA in just 5 minutes and set up the required hardware and software, please follow the instructions in the [Getting Started](../../../getting-started/README.md) section.

## Overview

There are several ways to setup a AudioQnA use case. Here in this tutorial, we will walk through how to enable the below list of microservices from OPEA GenAIComps to deploy a single node TGI megaservice solution.

1. Automatic Speech Recognition (ASR) Service
2. Large Language Models (LLM) Service 
3. Text-to-Speech (TTS) Service

The solution is aimed to show how to use ASR, TGI and TTS on Intel Xeon Scalable processors. We will go through how to setup docker container to start a microservices and megaservice . The solution will then utilize a sample audio file which is in waw format.

## Prerequisites

The first step is to clone the GenAIExamples and GenAIComps projects. GenAIComps are fundamental necessary components used to build the examples you find in GenAIExamples and deploy them as microservices. Set an environment variable for the desired release version with the number only (i.e. 1.0, 1.1, etc) and checkout using the tag with that version.

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

The example requires you to set the the following variables to deploy the microservices on
endpoint enabled with ports.

```bash
export host_ip=$(hostname -I | awk '{print $1}')
export HUGGINGFACEHUB_API_TOKEN=<your HF token>

export LLM_MODEL_ID=Intel/neural-chat-7b-v3-3

export MEGA_SERVICE_HOST_IP=${host_ip}
export WHISPER_SERVER_HOST_IP=${host_ip}
export SPEECHT5_SERVER_HOST_IP=${host_ip}
export LLM_SERVER_HOST_IP=${host_ip}
export GPT_SOVITS_SERVER_HOST_IP=${host_ip}

export WHISPER_SERVER_PORT=7066
export SPEECHT5_SERVER_PORT=7055
export GPT_SOVITS_SERVER_PORT=9880
export LLM_SERVER_PORT=3006

export BACKEND_SERVICE_ENDPOINT=http://${host_ip}:3008/v1/audioqna
```

Make sure to setup Proxies if you are behind a firewall
```bash
export no_proxy=${your_no_proxy},$host_ip
export http_proxy=${your_http_proxy}
export https_proxy=${your_http_proxy}
```

## Prepare (Building / Pulling) Docker images

This step involves either building or pulling four required Docker images. Each image serves a specific purpose in the AudioQnA architecture.

::::::{tab-set}

:::::{tab-item} Pull
:sync: Pull

If you decide to pull the docker containers and not build them locally, you can proceed to the next step where all the necessary containers will be pulled in from Docker Hub.

:::::
:::::{tab-item} Build
:sync: Build

Follow the steps below to build the docker images from within the `GenAIComps` folder.
**Note:** For RELEASE_VERSIONS older than 1.0, you will need to add a 'v' in front 
of ${RELEASE_VERSION} to reference the correct image on Docker Hub.

```bash
cd $WORKSPACE/GenAIComps
```

### Build ASR Image

First, build the Automatic Speech Recognition service image:

```bash
docker build -t opea/whisper:${RELEASE_VERSION}--build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/asr/src/integrations/dependency/whisper/Dockerfile .
```

### Build LLM Image

Intel Xeon optimized image hosted in huggingface repo will be used for TGI service: [ghcr.io/huggingface/text-generation-inference:2.4.0-intel-cpu](https://github.com/huggingface/text-generation-inference)

### Build TTS Image

Build the Text-to-Speech service image:

```bash
docker build -t opea/speecht5:${RELEASE_VERSION} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f comps/tts/src/integrations/dependency/speecht5/Dockerfile .

# multilang tts (optional)
docker build -t opea/gpt-sovits:${RELEASE_VERSION} --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy -f comps/tts/src/integrations/dependency/gpt-sovits/Dockerfile .
```

### Build MegaService Image

The Megaservice is a pipeline that channels data through different microservices, each performing varied tasks. We define the different microservices and the flow of data between them in the `audioqna.py` file.

Build the megaservice image for this use case.

```bash
cd $WORKSPACE/GenAIExamples/AudioQnA/
docker build --no-cache -t opea/audioqna:${RELEASE_VERSION} --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -f Dockerfile .
```

### Sanity Check

Before proceeding, verify that you have all required Docker images by running `docker images`. You should see the following images:

* opea/whisper:${RELEASE_VERSION}
* opea/speecht5:${RELEASE_VERSION}
* opea/audioqna:${RELEASE_VERSION}
* opea/gpt-sovits:${RELEASE_VERSION} (optional)

:::::
::::::

## Use Case Setup

The use case will use the following combination of the GenAIComps with the tools.

| Use Case Components | Tools         | Model                                | Service Type         |
|---------------------|---------------|--------------------------------------|----------------------|
| LLM                 | TGI           | Intel/neural-chat-7b-v3-3            | OPEA Microservice    |
| ASR                 |               | NA                                   | OPEA Microservice    |
| TTS                 |               | NA                                   | OPEA Microservice    |

Tools and models mentioned in the table are configurable either through the environment variable or `compose.yaml`

Set the necessary environment variables to setup the use case by running the `set_env.sh` script.
Here is where the environment variable `LLM_MODEL_ID` is set, and you can change it to another model by specifying the HuggingFace model card ID.

Run the `set_env.sh` script.
```bash
cd $WORKSPACE/GenAIExamples/AudioQnA/docker_compose
source ./set_env.sh
```

## Deploy the use case

In this tutorial, we will be deploying via docker compose with the provided YAML file. The docker compose instructions should start all the above-mentioned services as containers.

```bash
export MODEL_CACHE=./data

cd $WORKSPACE/GenAIExamples/AudioQnA/docker_compose/intel/cpu/xeon/
docker compose up -d

# multilang tts (optional)
docker compose -f compose_multilang.yaml up -d
```

Note: add the following environment variables in compose yaml if meet issues for downloading models:
```bash
HF_ENDPOINT: https://hf-mirror.com
HF_HUB_ENABLE_HF_TRANSFER: false
```

### Validate microservice

#### Check Env Variables

Check the startup log by `docker compose -f ./compose.yaml logs`.
The warning messages print out the variables if they are **NOT** set.

```bash
GenAIExamples/AudioQnA/docker_compose/intel/cpu/xeon$ sudo -E docker compose -f ./compose.yaml logs
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string. 
WARN[0000] The "no_proxy" variable is not set. Defaulting to a blank string.
```

#### Check the container status

Check if all the containers launched via docker compose have started.
For example, the AudioQnA example starts 5 docker containers (services), check these docker containers are all running, i.e., all the containers `STATUS` are `Up`.

To do a quick sanity check, try `docker ps -a` to see if all the containers are running.

```bash
| CONTAINER ID | IMAGE                                                             | COMMAND                   | CREATED         | STATUS                            | PORTS                                      | NAMES                           |
|--------------|-------------------------------------------------------------------|---------------------------|----------------|------------------------------------|---------------------------------------------|---------------------------------|
| 83c27b0968f3 | opea/audioqna-ui:${RELEASE_VERSION}                               | `"docker-entrypoint.s…"`  | 37 minutes ago | Up 37 minutes                      | 0.0.0.0:5173->5173/tcp, [::]:5173->5173/tcp | audioqna-xeon-ui-server         |
| 0bb32d7b586f | opea/audioqna:${RELEASE_VERSION}                                  | `"python audioqna.py"`    | 37 minutes ago | Up 37 minutes                      | 0.0.0.0:3008->8888/tcp, [::]:3008->8888/tcp | audioqna-xeon-backend-server    |
| 5eab9c5d7199 | ghcr.io/huggingface/text-generation-inference:2.4.0-intel-cpu     | `"text-generation-lau…"`  | 37 minutes ago | Up 37 minutes (unhealthy)          | 0.0.0.0:3006->80/tcp, [::]:3006->80/tcp     | tgi-service                     |
| bbde822725d4 | opea/whisper:${RELEASE_VERSION}                                   | `"python whisper_serv…"`  | 37 minutes ago | Up 37 minutes                      | 0.0.0.0:7066->7066/tcp, [::]:7066->7066/tcp | whisper-service                 |
| 1290ccd09182 | opea/speecht5:${RELEASE_VERSION}                                  | `"python speecht5_ser…"`  | 37 minutes ago | Up 37 minutes                      | 0.0.0.0:7055->7055/tcp, [::]:7055->7055/tcp | speecht5-service                |

```

## Interacting with AudioQnA deployment

In this section, you will walk through the different ways to interact with the deployed microservices.

### Whisper Service

```bash
# whisper service
wget https://github.com/intel/intel-extension-for-transformers/raw/main/intel_extension_for_transformers/neural_chat/assets/audio/sample.wav
curl http://${host_ip}:7066/v1/audio/transcriptions \
  -H "Content-Type: multipart/form-data" \
  -F file="@./sample.wav" \
  -F model="openai/whisper-small"
```

Whisper service generates text for the input audio file. Here is the expected result from Whisper:

```bash
{"text":"who is pat gelsinger"}
```

### TGI Service

```bash
# tgi service
curl http://${host_ip}:3006/generate \
  -X POST \
  -d '{"inputs":"What is Deep Learning?","parameters":{"max_new_tokens":17, "do_sample": true}}' \
  -H 'Content-Type: application/json'
```

TGI service handles the core language model operations. Here is the expected result from TGI:

```bash
{"generated_text":"\n\nDeep learning is a subset of machine learning and broadly defined as techniques to"}
```
### Speecht5 Service

```bash
# speecht5 service
curl http://${host_ip}:7055/v1/audio/speech -XPOST -d '{"input": "Who are you?"}' -H 'Content-Type: application/json' --output speech.mp3
```

Speecht5 service generates an audio file from the given sentense. The expected outputs is an audio file that says "Who are you?".

### MegaService

The AudioQnA megaservice orchestrates the entire conversation process. Test it with a empty audio:

```bash
# if you are using speecht5 as the tts service, voice can be "default" or "male"
# if you are using gpt-sovits for the tts service, you can set the reference audio following https://github.com/opea-project/GenAIComps/blob/main/comps/tts/src/integrations/dependency/gpt-sovits/README.md
curl http://${host_ip}:3008/v1/audioqna \
  -X POST \
  -d '{"audio": "UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA", "max_tokens":64, "voice":"default"}' \
  -H 'Content-Type: application/json' | sed 's/^"//;s/"$//' | base64 -d > output.wav
```

The expected output is a meaningful audio file.

## Check the docker container logs

Following is an example of debugging using Docker logs:

Check the log of the container using:

`docker logs <CONTAINER ID> -t`

View the docker input parameters in $WORKSPACE/GenAIExamples/AudioQnA/docker_compose/intel/cpu/xeon/compose.yaml

### Stop the services

Once you are done with the entire pipeline and wish to stop and remove all the containers, use the command below:

```bash
docker compose -f compose.yaml down
```
