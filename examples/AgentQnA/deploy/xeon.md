# Single node on-prem deployment with Docker Compose on Xeon Scalable processors

1. [Optional] Build `Agent` docker image

```
git clone https://github.com/opea-project/GenAIComps.git
cd GenAIComps
docker build -t opea/agent-langchain:latest -f comps/agent/langchain/Dockerfile .
```

2. Launch Tool service

In this example, we will use some of the mock APIs provided in the Meta CRAG KDD Challenge to demonstrate the benefits of gaining additional context from mock knowledge graphs.

```
docker run -d -p=8080:8000 docker.io/aicrowd/kdd-cup-24-crag-mock-api:v0
```

3. clone repo
```
export WORKDIR=$(pwd)
git clone https://github.com/opea-project/GenAIExamples.git

export TOOLSET_PATH=$WORKDIR/GenAIExamples/AgentQnA/tools/

# optional: OPANAI_API_KEY
export OPENAI_API_KEY=<your-openai-key>
```

4. launch `Agent` service

The configurations of the supervisor agent and the worker agent are defined in the docker-compose yaml file. We currently use openAI GPT-4o-mini as LLM, and we plan to add support for llama3.1-70B-instruct (served by TGI-Gaudi) in a subsequent release. To use openai llm, run command below.

```
cd $WORKDIR/GenAIExamples/AgentQnA/docker_compose/intel/cpu/xeon
bash launch_agent_service_openai.sh
```