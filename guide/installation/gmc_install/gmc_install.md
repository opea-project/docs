# GenAI-microservices-connector(GMC) Installation

This document will introduce the GenAI Microservices Connector (GMC) and its installation. It will then use the ChatQnA pipeline as a use case to demonstrate GMC's functionalities.

## GenAI-microservices-connector(GMC)

GMC can be used to compose and adjust GenAI pipelines dynamically on Kubernetes. It can leverage the microservices provided by GenAIComps and external services to compose GenAI pipelines. External services might be running in a public cloud or on-prem. Just provide an URL and access details such as an API key and ensure there is network connectivity. It also allows users to adjust the pipeline on the fly like switching to a different Large language Model(LLM), adding new functions into the chain(like adding guardrails), etc. GMC supports different types of steps in the pipeline, like sequential, parallel and conditional. For more information: https://github.com/opea-project/GenAIInfra/tree/main/microservices-connector

## Install GMC

**Prerequisites**

- For the ChatQnA example ensure your cluster has a running Kubernetes cluster with at least 16 CPUs, 32GB of memory, and 100GB of disk space. To install a Kubernetes cluster refer to:
["Kubernetes installation"](../k8s_install/README.md) 

**Download the GMC github repository**

```sh
git clone https://github.com/opea-project/GenAIInfra.git && cd GenAIInfra/microservices-connector
```

**Build and push your image to the location specified by `CTR_IMG`:**

```sh
make docker.build docker.push CTR_IMG=<some-registry>/gmcmanager:<tag>
```

**NOTE:** This image will be published in the personal registry you specified.
And it is required to have access to pull the image from the working environment.
Make sure you have the proper permissions to the registry if the above commands don’t work.

**Install GMC CRD**

```sh
kubectl apply -f config/crd/bases/gmc.opea.io_gmconnectors.yaml
```

**Get related manifests for GenAI Components**

```sh
mkdir -p $(pwd)/config/manifests
cp $(dirname $(pwd))/manifests/ChatQnA/*.yaml -p $(pwd)/config/manifests/
```

**Copy GMC router manifest**

```sh
cp $(pwd)/config/gmcrouter/gmc-router.yaml -p $(pwd)/config/manifests/
```

**Create Namespace for gmcmanager deployment**

```sh
export SYSTEM_NAMESPACE=system
kubectl create namespace $SYSTEM_NAMESPACE
```

**NOTE:** Please use the exact same `SYSTEM_NAMESPACE` value setting you used while deploying gmc-manager.yaml and gmc-manager-rbac.yaml.

**Create ConfigMap for GMC to hold GenAI Components and GMC Router manifests**

```sh
kubectl create configmap gmcyaml -n $SYSTEM_NAMESPACE --from-file $(pwd)/config/manifests
```

**NOTE:** The configmap name `gmcyaml' is defined in gmcmanager deployment Spec. Please modify accordingly if you want use a different name for the configmap.

**Install GMC manager**

```sh
kubectl apply -f $(pwd)/config/rbac/gmc-manager-rbac.yaml
kubectl apply -f $(pwd)/config/manager/gmc-manager.yaml
```

**Check the installation result**

```sh
kubectl get pods -n system
NAME                              READY   STATUS    RESTARTS   AGE
gmc-controller-78f9c748cb-ltcdv   1/1     Running   0          3m
```

## Use GMC to compose a chatQnA Pipeline
A sample for chatQnA can be found at config/samples/chatQnA_xeon.yaml

**Deploy chatQnA GMC custom resource**

```sh
kubectl create ns chatqa
kubectl apply -f $(pwd)/config/samples/chatQnA_xeon.yaml
```

**GMC will reconcile chatQnA custom resource and get all related components/services ready**

```sh
kubectl get service -n chatqa
```

**Check GMC chatQnA custom resource to get access URL for the pipeline**

```bash
$kubectl get gmconnectors.gmc.opea.io -n chatqa
NAME     URL                                                      READY     AGE
chatqa   http://router-service.chatqa.svc.cluster.local:8080      8/0/8     3m
```

**Deploy one client pod for testing the chatQnA application**

```bash
kubectl create deployment client-test -n chatqa --image=python:3.8.13 -- sleep infinity
```

**Access the pipeline using the above URL from the client pod**

```bash
export CLIENT_POD=$(kubectl get pod -n chatqa -l app=client-test -o jsonpath={.items..metadata.name})
export accessUrl=$(kubectl get gmc -n chatqa -o jsonpath="{.items[?(@.metadata.name=='chatqa')].status.accessUrl}")
kubectl exec "$CLIENT_POD" -n chatqa -- curl $accessUrl  -X POST  -d '{"text":"What is the revenue of Nike in 2023?","parameters":{"max_new_tokens":17, "do_sample": true}}' -H 'Content-Type: application/json'
```
