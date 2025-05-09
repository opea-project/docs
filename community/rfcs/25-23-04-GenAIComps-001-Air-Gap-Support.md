# Support Air-gapped environment

This RFC is for running OPEA microservices in an air-gapped environment.

Related tickets:
- https://github.com/opea-project/GenAIExamples/issues/1405
- https://github.com/opea-project/GenAIComps/issues/1480

## Author(s)

[Lianhao Lu](https://github.com/lianhao)

## Status

`Under Review`

## Objective

An air-gapped computer or network is one that has no network interfaces, either wired or wireless, connected to outside networks(e.g. Internet, etc.). Many enterprises have network security policies that prohibit the computers in the enterprise internal network to have any kind of ability to send/receive data to/from the outside networks. 

This RFC discusses how to support running OPEA microservices in such an air-gapped environment, including the methodology to find out the what kind of data need to be pre-downloaded, where to store the pre-downloaded data, and how this will affect the deployment, etc.

### Online data types
There are some OPEA microservices require downloading data from Internet during runtime, this kind of data includes:

#### User configurable AI model data
Some OPEA microservices allow the user to configure the AI model to use. Model data can already be pre-downloaded and used by the OPEA microservices running in air-gapped environment, but it's rather manual process and not documented for all the applications yet.

#### Hard-coded AI model data
Some OPEA microservices silently download some AI model data from the Internet during runtime. This kind of data to be downloaded is either hardcoded in the OPEA microservices, or is not explicitly exposed to the end user for configuration. For example, the `dataprep` microservice requires to download the AI model `unstructuredio/yolo_x_layout` during runtime to process unstructured input data, and currently is not configurable by the end-user.

#### Other hard-coded data
Some OPEA microservices silently download additional data other than AI models during runtime, e.g. `dataprep`, `retriever` and `gpt-sovits` need to download a subset of `nltk` data, `speecht5` needs to download data from [intel-extension-for-transformers](https://github.com/intel/intel-extension-for-transformers/tree/main/intel_extension_for_transformers/neural_chat/assets/speaker_embeddings), etc.

In this RFC, we'll mainly cover the hard-coded online data, given that user-configurable model data is already handled for pre-download.

## Motivation

When trying to deploy the OPEA microservices in some customer air-gapped environments, we've found that there are quite some OPEA microservices that need to download data from the internet during runtime, many of them requiring special tweaks to download. We want to make sure that all OPEA microservices can be run in the air-gapped environment in a uniform way.

## Design Proposal

### Ways to verify
To quickly verify if a OPEA microservice support air-gapped mode or not, and what kind of online data it's downloading, we can use the following steps:

 1. Deploy the microservice in one of the 3 following environment:
    - A real air-gapped environment (Docker or K8s)
    - A K8s environment which disables K8s DNS forwarding(i.e. remove the `forward` part in `kubectl -n kube-system edit cm coredns`, and restart `coredns` related pods)
    - Environment requiring proxy, with `http_proxy` and `https_proxy` set to a non existent proxy servers, e.g. `http://localhost:54321`.

 2. Send requests to the microservice under verification
     We need to make sure that all the sent out requests should have a decent coverage of the internal data flow of that microservices, because sometimes it's not the microservice itself is downloading online data, but the dependent modules.

 3. Check the requests return status and microservice logs to find out whether it supports air-gapped mode and what kind of online data it's downloading if it's not.

### Hard-coded AI model data

Since we're not allowed to distribute AI model data in the microservice's container image, we need treat that like user-configurable model data; make sure there is a way to `mount` the user pre-downloaded AI model data into the microservice's runtime so that the microservice itself can run in the air-gapped environment.

We also need to automate downloading of that data, and document how to `mount` in the deployment document of that microservice.

### Other hard-coded data

To minimize the deployment complexity, for small size online data which is NOT shared by multiple microservices, we should have them downloaded in the container image, so that the microservice itself doesn't need to download it during runtime.

For online data which are used by multiple microservices, e.g. `nltk` data,  depends on its size, we can have them pre downloaded in the container image if it will not increase the image size significantly. For large size data, we should follow the `Hard-coded AI model data` method to support running the microservice in the air gapped mode.


## Alternatives Considered

Using the `Hard-coded AI model data` method for `Other hard-coded data` type, a.k.a pre-download the other hard coded data and make sure there is a way to `mount` the pre-downloaded data into the microservice's runtime. However, since different microservices may use different forms of hard-coded online data, this methods introduces much more complexity to the deployment.

## Compatibility

n/a.

## Miscellaneous

List other information user and developer may care about, such as:

- Engineering Impact: 
  - increase container image build time
  - decrease the container image startup time.

- Staging plan:
  - Using the methods listed in the above section `Ways to verify` to find all the microservices which does not support air-gapped mode, and create corresponding Github issues.
  - For each such microservice, figure out the online data type and enhance it to support air gapped mode.

- CI env to test this functionality: Since this is a common requirement to all OPEA microservices, we need to setup an CI/CD test task.
