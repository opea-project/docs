RFC Template
==================

## RFC Title

Deploy GenAIComps building blocks on Kubernetes

## RFC Content

### Author

[yongfengdu](https://github.com/yongfengdu),[leslieluyu](https://github.com/leslieluyu)

### Status

`Under Review`

### Objective

Define how the GenAIComps components should be deployed on kubernetes. And define
the interface for GMC to call these building blocks to compose e2e AI application.

Non-Goal: Pipeline to connect all microservices is out of scope.

### Motivation

GenAIComps defined building blocks for AI components, and provided instructions on how to run with docker/docker-compose.
This proposal will provide a way to run these components on kubernetes.

### Design Proposal

Yaml files are the straightforward way to deploy applications on kubernetes,
but when we are providing deployment for more examples in GenAIExamples,
there will be a lot of duplicated codes. This make the yaml files hard to
maintain.

The proposal is to provide helm charts for GenAIComps components, and define a
few variables like model name, cached model path etc, so we can generate the
yaml files automatically by "helm template" for each GenAIExamples deployment.

In detail, the helm chart for each component will be maintained at this directory, more components will be added later:

GenAIInfra/helm-charts/common/{llm-uservice|reranking-usvc|retriever-usvc|embedding-usvc|tgi|tei|teirerank|redis-vector-db}

Among these components, there are 2 levels, the llm-uservice|reranking-usvc|retriever-usvc|embedding-usvc are microservices components used to build pipeline, and tgi|tei|teirerank|redis-vector-db are backends called by the microservcies.

Helm Charts for components will be deployed and verified by CICD systems as single function.

Proposals for GMC on how to use the helm charts, use llm-uservice as example:

## Option1: Use yaml files automatically generated from helm charts.

We can generate the yaml files for CodeTrans with the following commands:

```console
cd GenAIInfra/helm-charts/common
helm dependency update llm-uservice
export HFTOKEN="insert-your-huggingface-token-here"
export MODELDIR="/mnt"
export MODELNAME="HuggingFaceH4/mistral-7b-grok"
helm template codetrans llm-uservice --set global.HUGGINGFACEHUB_API_TOKEN=${HFTOKEN} --set tgi.volume=${MODELDIR} --set tgi.LLM_MODEL_ID=${MODELNAME} > ../../manifests/CodeTrans/xeon/llm.yaml
```

We'll set values like Model Name in the process of generating yaml file, and GMC can use this yaml file directly with few customization.

## Option2: Generate yaml files for common components regardless how the Examples/Pipeline are using it.

This way, the yaml files will not contain values for specified workloads, GMC use this file as template to modify/inject values using its own way. 

```console
cd GenAIInfra/helm-charts/common
helm dependency update llm-uservice
export HFTOKEN="insert-your-huggingface-token-here"
export MODELDIR="/mnt"
export MODELNAME="HuggingFaceH4/mistral-7b-grok"
helm template WLNAME llm-uservice --set global.HUGGINGFACEHUB_API_TOKEN=${HFTOKEN} --set tgi.volume=${MODELDIR} --set tgi.LLM_MODEL_ID=${MODELNAME} > ../../manifests/common/xeon/llm.yaml
```

## Option3: GMC use go helm client to generate yaml files.

This way, we'll not provide auto generated yaml files, GMC will set the values.yaml, or use --set option to customize yaml files at the time of calling helm client. In my opinion, this way is easiest to integrate and flexible.

Refer to https://pkg.go.dev/github.com/mittwald/go-helm-client#HelmClient.TemplateChart

## To discuss

The microservices(llm-uservice|reranking-usvc|embedding-usvc|retriever-usvc) are components of building pipelines, and the underlying service(tgi|tei etc) can be hided from end users as implementation details. We will implement more choices of inference server like vLLM/RayServe as replacable backend in the future.

Shall we provide both tgi and llm-uservice to GMC? If separated components are prefered, we'll need the remove the dependency of llm over tgi in the helm chart.


### Alternatives Considered

Use configmap to config the environment variables for yaml file, like the HUGGINGFACEHUB_API_TOKEN, MODEL_ID.

This way we can provide reconfig for envrionment variables easily, but it's hard to modify other values which are not passed as env variables like Model_Cache_Dir for the deployment, the namespace etc.

### Compatibility

list possible incompatible interface or workflow changes if exists.

### Miscs

List other information user and developer may care about, such as:

- Performance Impact, such as speed, memory, accuracy.
- Engineering Impact, such as binary size, startup time, build time, test times.
- Security Impact, such as code vulnerability.
- TODO List or staging plan.
