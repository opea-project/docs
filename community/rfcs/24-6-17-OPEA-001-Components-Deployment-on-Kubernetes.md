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


=============================================================================================
## The Proposal for the GenAI helm-charts/manifests  
<img width="1379" alt="image" src="https://github.com/yongfengdu/docs/assets/5109898/ae637f30-dfc0-4c6e-a624-7c8a1c41ca4e">


### Steps:

1. Translate workload to helmchart : from Docker-Compose + components  in GenAIExamles&GenAIComps 
2. export helmchart  to manifests 
3. GMC integrates the components (replace the backend in each workload)
4. Submit each GenAI workloads into GenAIExamples/${workloadName}/kubernetes


### Example  of ChatQnA
1. Use helm update to get dependent charts
   `helm dependency update`

2. Use helm template to export manifests files

   ```
   $ export releaseName=chatqna
   $ helm template ${releaseName} chatqna/  --output-dir test/ \
      --set llm-uservice.HUGGINGFACEHUB_API_TOKEN="${HFTOKEN}" \
      --set global.http_proxy=http://192.168.1.253:3128 \
      --set global.https_proxy=http://192.168.1.253:3128 \
      --set llm-uservice.tgi.LLM_MODEL_ID="/data/neural-chat-7b-v3-3" \
      --set llm-uservice.tgi.volume="/mnt/models" \
      --set embedding-usvc.tei.volume="/mnt/models" \
      --set reranking-usvc.teirerank.volume="/mnt/models" \
      --values chatqna/gaudi-values.yaml \
      --create-namespace 
   ```
3. the yamls exported
   ![image](https://github.com/yongfengdu/docs/assets/5109898/d8d9f8d5-7fc0-4acf-a42c-eeee9f3abdd6)

4. only for verify:
   ```
   ### apply&delete the manifests:
    kubectl apply -f ./test/chatqna -R
    kubectl delete -f test/chatqna -R
   ```
5. replace each backend with GMC
6. use GMC to orchestrate the components manifests

### Several Points:
1. the helm-charts of each workload only exist in GenAIInfra
2. the GMC will orchestrate the workload
3. the GMC + yamls of components will submit to each workload in GenAIExamples



