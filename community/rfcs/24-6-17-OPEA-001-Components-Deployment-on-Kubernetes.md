RFC Template
==================

## RFC Title

Deploy GenAIComps on Kubernetes

## RFC Content

### Author

[yongfengdu](https://github.com/yongfengdu),[leslieluyu](https://github.com/leslieluyu)

### Status

`Under Review`

### Objective

Define how the GenAIComps/Microservices should be deployed on kubernetes.

Non-Goal: Pipeline to connect all microservices is out of scope.

### Motivation

GenAIComps defined building blocks for AI components, and provided instructions on how to run with docker/docker-compose.
This proposal will provide a way to run these components on kubernetes.

### Design Proposal

Yaml files are the straightforward way to deploy applications on kubernetes,
but when we are providing deployment for more examples in GenAIExamples,
there will be a lot of duplicated codes. This make the yaml files hard to
maintain.

The proposal is to provide helm chart for GenAIComps components, and define a
few variables like model name, so we can generate the yaml files automatically
by "helm template" for each GenAIExamples deployment.

In detail, the helm chart for each component will be maintained at this directory:

GenAIInfra/helm-charts/common

For example llm-uservice, then we can generate the yaml files for CodeTrans this way:

```console
cd GenAIInfra/helm-charts/common
helm dependency update llm-uservice
export HFTOKEN="insert-your-huggingface-token-here"
export MODELDIR="/mnt"
export MODELNAME="HuggingFaceH4/mistral-7b-grok"
helm template codetrans llm-uservice --set global.HUGGINGFACEHUB_API_TOKEN=${HFTOKEN} --set tgi.volume=${MODELDIR} --set tgi.LLM_MODEL_ID=${MODELNAME} > ../../manifests/CodeTrans/xeon/llm.yaml
```

We'll keep a copy of the generated yaml files at GenAIInfra/manifests/${WORKLOAD}/[xeon|gaudi] in case anyone want to use it directly with "kubectl apply -f".

### Alternatives Considered

List other alternatives if have, and corresponding pros/cons to each proposal.

### Compatibility

list possible incompatible interface or workflow changes if exists.

### Miscs

List other information user and developer may care about, such as:

- Performance Impact, such as speed, memory, accuracy.
- Engineering Impact, such as binary size, startup time, build time, test times.
- Security Impact, such as code vulnerability.
- TODO List or staging plan. 

