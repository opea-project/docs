# Getting Started with OPEA

## Prerequisites

To get started with OPEA you need the right hardware and basic software setup.

- Hardware Requirements: For the hardware configuration, If you need Hardware Access visit the [Intel Tiber Developer Cloud](https://cloud.intel.com) to select from options such as Xeon or Gaudi processors that meet the necessary specifications.

- Software Requirements: Refer to the [Support Matrix](https://github.com/opea-project/GenAIExamples/blob/main/README.md#getting-started) to ensure you have the required software components in place.

Note : If you are deploying it on cloud, say AWS, select a VM instance from R7iz or m7i family of instances with base OS as Ubuntu 22.04 (AWS ami id : ami-05134c8ef96964280). Use the command below to install docker on a clean machine.
```
wget https://raw.githubusercontent.com/opea-project/GenAIExamples/refs/heads/main/ChatQnA/docker_compose/install_docker.sh
chmod +x install_docker.sh
./install_docker.sh
```
## Understanding OPEA's Core Components

Before moving forward, it's important to familiarize yourself with two key elements of OPEA: GenAIComps and GenAIExamples.

- GenAIComps is a collection of microservice components that form a service-based toolkit. This includes a variety of services such as llm (language learning models), embedding, and reranking, among others.
- While GenAIComps offers a range of microservices, GenAIExamples provides practical, deployable solutions to help users implement these services effectively. Examples include ChatQnA and DocSum, which leverage the microservices for specific applications.

## Visual Guide to Deployment
To illustrate, here's a simplified visual guide on deploying a ChatQnA GenAIExample, showcasing how you can set up this solution in just a few steps.

![Getting started with OPEA](assets/getting_started.gif)

## Setup ChatQnA Parameters
To deploy ChatQnA services, follow these steps:

```
git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples/ChatQnA
```

### Set the required environment variables:
```
# Example: host_ip="192.168.1.1"
export host_ip="External_Public_IP"
# Example: no_proxy="localhost, 127.0.0.1, 192.168.1.1"
export no_proxy="Your_No_Proxy"
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

If you are in a proxy environment, also set the proxy-related environment variables:
```
export http_proxy="Your_HTTP_Proxy"
export https_proxy="Your_HTTPs_Proxy"
```

Set up other specific use-case environment variables by choosing one of these options, according to your hardware:

```
# on Xeon
source ./docker_compose/intel/cpu/xeon/set_env.sh
# on Gaudi
source ./docker_compose/intel/hpu/gaudi/set_env.sh
# on Nvidia GPU
source ./docker_compose/nvidia/gpu/set_env.sh
```

## Deploy ChatQnA Megaservice and Microservices
Select the directory containing the `compose.yaml` file that matches your hardware.
```
#xeon
cd docker_compose/intel/cpu/xeon/
#gaudi
cd docker_compose/intel/hpu/gaudi/
#nvidia
cd docker_compose/nvidia/gpu/
```
Now we can start the services
```
docker compose up -d
```
It will automatically download the needed docker images from docker hub:

- docker pull opea/chatqna:latest
- docker pull opea/chatqna-ui:latest

In the following cases, you will need to build the docker image from source by yourself.

- The docker image failed to download. (You may want to first check the
  [Docker Images](https://github.com/opea-project/GenAIExamples/blob/main/docker_images_list.md)
  list and verify that the docker image you're downloading exists on dockerhub.)
- You want to use a different version than latest.

Refer to the {ref}`ChatQnA Example Deployment Options <chatqna-example-deployment>` section for building from source instructions matching your hardware.

## Interact with ChatQnA Megaservice and Microservice
```
curl http://${host_ip}:8888/v1/chatqna \
    -H "Content-Type: application/json" \
    -d '{
        "messages": "What is the revenue of Nike in 2023?"
    }'
```
This command will provide the response as a stream of text. You can modify the `message` parameter in the `curl` command and interact with the ChatQnA service.

## What’s Next

- Try  [GenAIExamples](/examples/index.rst) in-detail starting with [ChatQnA](/examples/ChatQnA/ChatQnA_Guide.rst) example; this is a great example to orient yourself to the OPEA ecosystem.
- Try [GenAIComps](/microservices/index.rst) to build microservices.

### Get Involved

Have you ideas and skills to build out genAI components, microservices, and solutions? Would you like  to be a part of this  evolving technology in its early stages? Welcome! 
* Register for our mailing list: 
    * [General Mailing List](https://lists.lfaidata.foundation/g/OPEA-announce) 
    * [Technical Discussions](https://lists.lfaidata.foundation/g/OPEA-technical-discuss)
* Subscribe to the working group mailing lists that interest  you
    * [End User](https://lists.lfaidata.foundation/g/OPEA-End-User) 
    * [Evaluation](https://lists.lfaidata.foundation/g/OPEA-Evaluation) 
    * [Community](https://lists.lfaidata.foundation/g/OPEA-Community) 
    * [Research](https://lists.lfaidata.foundation/g/OPEA-Research) 
    * [Security](https://lists.lfaidata.foundation/g/OPEA-Security) 
* Go to the [Community Section](https://opea-project.github.io/latest/community/index.html) of the OPEA repo for Contribution Guidelines and step by step instructions. 
* Attend any of our [community events and hackathons](https://wiki.lfaidata.foundation/display/DL/OPEA+Community+Events). 

Current GenAI Examples
- Simple chatbot that uses retrieval augmented generation (RAG) architecture. [ChatQnA](/examples/ChatQnA/ChatQnA_Guide.rst) 
- Code generation, from enabling non-programmers to generate code to improving productivity with code completion of complex applications. [CodeGen]
- Make your applications more flexible by porting to different languages. [CodeTrans](https://opea-project.github.io/latest/GenAIExamples/CodeGen/README.html)
- Create summaries of news articles, research papers, technical documents, etc. to streamline content systems. [DocSum](https://opea-project.github.io/latest/GenAIExamples/DocSum/README.html)
- Mimic human behavior by iteratively searching, selecting, and synthesizing information across large bodies of content. [SearchQnA](https://opea-project.github.io/latest/GenAIExamples/SearchQnA/README.html)
- Provide critical content to your customers by automatically generating Frequently Asked Questions (FAQ) resources. [FaqGen](https://opea-project.github.io/latest/GenAIExamples/FaqGen/README.html)
- Provide text descriptions from pictures, enabling your users to inquire directly about products, services, sites, etc. [VisualQnA](https://opea-project.github.io/latest/GenAIExamples/VisualQnA/README.html)
- Reduce language barriers through customizable text translation systems. [Translation](https://opea-project.github.io/latest/GenAIExamples/Translation/README.html) 

