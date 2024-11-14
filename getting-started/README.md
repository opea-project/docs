# Getting Started with OPEA
In this document, we provide a tailored guide to deploying the ChatQnA application in OPEA GenAI Examples across multiple cloud platforms, including Amazon Web Services (AWS), Google Cloud Platform (GCP), IBM Cloud, Microsoft Azure and Oracle Cloud Infrastructure, enabling you to choose the best fit for your specific needs and requirements. For additional deployment targets, see the [ChatQnA Sample Guide](https://opea-project.github.io/latest/examples/ChatQnA/ChatQnA_Guide.html).

## Understanding OPEA's Core Components

Before moving forward, it's important to familiarize yourself with two key elements of OPEA: GenAIComps and GenAIExamples.

- GenAIComps is a collection of microservice components that form a service-based toolkit. This includes a variety of services such as llm (large language models), embedding, and reranking, among others.
- GenAIExamples provides practical and deployable solutions to help users implement these services effectively. Examples include ChatQnA and DocSum, which leverage the microservices for specific applications.


## Prerequisites

## Create and Configure a Virtual Server

::::{tab-set}
:::{tab-item} Amazon Web Services
:sync: AWS

1. Navigate to [AWS console](https://console.aws.amazon.com/console/home) – Search EC2 in the search bar and select it. Click the "Launch Instance" button highlighted in orange.

2. Provide a name to the VM.

3. In Quick Start, select the base OS as Ubuntu (`ami-id : ami-04dd23e62ed049936`).

4. Select an Instance type that is based on Intel hardware.

>**Note**: We recommend selecting a `m7i.4xlarge` or larger instance with an Intel(R) 4th Gen Xeon(C) Scalable Processor. For more information on virtual servers on AWS visit [here](https://aws.amazon.com/intel/).

5. Next, create a new key pair, give it a name or select one from the existing key pairs.

6. Under Network settings select an existing security group. If there is none, create a new one by selecting the Create security group radio button and select the Allow SSH traffic and Allow HTTP traffic check box.

7. Configure the storage to 100 GiB and click "Launch Instance".

8. Click on the "connect" button on the top right and connect using your preferred method.

9. Look up Security Groups in the search bar and select the security group used when creating the instance.

10. Click on the Edit inbound rules on the right side of the window.

11.  Select Add rule at the bottom, and create a rule with type as Custom TCP , port range as 80 and source as 0.0.0.0/0 . Learn more about [editing inbound/outbound rules](https://docs.aws.amazon.com/finspace/latest/userguide/step5-config-inbound-rule.html)

:::
:::{tab-item} Google Cloud Platform
:sync: GCP

1. Navigate to [GCP console](https://console.cloud.google.com/) – Click the "Create a VM" button.

2. Provide a name to the VM.

3. Select the base OS as `Ubuntu 24.04 LTS` from Marketplace .

4. Select an Instance type that is based on Intel hardware.

> **Note:**   We recommend selecting a `c4-standard-32` or larger instance with an Intel(R) 4th Gen Xeon(C) Scalable Processor, and the minimum supported c3 instance type is c3-standard-8 with 32GB memory. For more information, visit [virtual servers on GCP](https://cloud.google.com/intel).

5. Under Firewall settings select “Allow HTTP traffic” to access ChatQnA UI web portal.

6. Change the Boot disk to 100 GiB and click "Create".

7. Use any preferred SSH method such as "Open in browser window" to connect to the instance.

:::
:::{tab-item} IBM Cloud
:sync: IBM Cloud

1. Navigate to [IBM Cloud](https://cloud.ibm.com). - Click the "Create resource" button at the top right of the screen. Select "Compute" from the options available and select "Virtual Server for VPC"

2. Select a location for the instance. Assign a name to it.

3. Under Stock Images, select Ubuntu 24.04 (`ibm-ubuntu-24-04-6-minimal-amd64-1`)

4. Select a virtual server.

> **Note:** We recommend selecting a 3-series instance with an Intel(R) 4th Gen Xeon(C) Scalable Processor, such as `bx3d-16x80` or above. For more information on virtual servers on IBM cloud visit [Intel® solutions on IBM Cloud®](https://www.ibm.com/cloud/intel).

5. Add an SSH key to the instance, if necessary, create one first.

6. Click on "Create virtual server".

7. Once the instance is running, create and attach a "Floating IP" to the instance. For more information visit [this](https://cloud.ibm.com/docs/vpc?topic=vpc-fip-working&interface=ui) site

8. Under "Infrastructure" in the left pane, go to Network/Security groups/<Your Security Group>/Rules

9. Select "Create"

10. Enable inbound traffic for port 80. For more information on editing inbound/outbound rules, click [here](https://cloud.ibm.com/docs/vpc?topic=vpc-updating-the-default-security-group&interface=ui)

11. ssh into the instance using the floating IP (`ssh -i <key> ubuntu@<floating-ip>`)
:::
:::{tab-item} Microsoft Azure
:sync: Azure

1. Navigate to [Microsoft Azure](portal.azure.com) – Select the "Skip" button on the bottom right to land on the service offerings page. Search for "Virtual Machines" in the search bar and select it. Click the "Create" button and select "Azure Virtual Machine".

2. Select an existing "Resource group" from the drop down or click "Create" for a new Resource group and give it a name. If you have issues refer to [cannot create resource groups](https://learn.microsoft.com/en-us/answers/questions/1520133/cannot-create-resource-groups).

3. Provide a name to the VM and select the base OS as `Ubuntu 24.04 LTS`

4. Select x64 in VM architecture.

5. Select an Instance type that is based on Intel hardware.

>**Note**: We recommend selecting a `Standard_D16ds_v5` instance or larger with an Intel(R) 3rd/4th  Gen Xeon(C) Scalable Processor. You can find this family of instances in the (US) West US Region. Visit for more information [virtual machines on Azure](https://azure.microsoft.com/en-us/partners/directory/intel-corporation).

6. Select Password as Authentication type and create username and password for your instance.

7. Choose the Allow selected ports in Inbound port rule section and select HTTP.

8. Click "Next: Disk" button and select OS disk size as 128GiB.

9. Click on "Review + Create" to launch the VM.

10. Click Go to resource -> Connect -> Connect -> SSH using Azure CLI. Accept the terms and then select "Configure + connect"

>**Note**: If you have issues connecting to the instance with SSH, you could use instead Bastion with your username and password.
:::
:::{tab-item} Oracle Cloud Infrastructure
:sync: OCI

1. Login to [Oracle Cloud Console](https://www.oracle.com/cloud/sign-in.html?redirect_uri=https%3A%2F%2Fcloud.oracle.com%2F) – Then navigate to [Compute Instances](https://cloud.oracle.com/compute/instances). Click the "Create Instance" button. 

2. Provide a name to the VM and select the placement in the availability domains. 

3. In Image and Shape section click "Change Image" > "Ubuntu" and then select `Canonical  Ubuntu 24.04`. Submit using the "Select  Image"  button at the bottom. 

4. Click the "Change Shape"   >  "Bare Metal Machine"  then select the `BM.Standard3.64`. Submit using the "Select Shape" button at the bottom. 

5. Select the VCN and the public subnet that the server needs to reside in.  If a new VCN/Subnet needs to be created then select the "Create new virtual cloud network"  and the "Create new public subnet" to create a subnet that is exposed to the internet.  

6. Next, save a private key by or upload an existing public key. 

7. Specify a boot volume size of 100 GiB with 30 VPU units of performance. 

8. Click Create to launch the instance.  

9. Note the public IP address of the machine once its launched. 

10. Once the instance is launched, click on the subnet in the Primary VNIC section. Then click on the "Default Security List for vcn-xxxxxxxx-xxxx" , click on the "Add Ingress Rules".  Add the following information:
    Source CIDR: 0.0.0.0/0  
    Source Port Range : All 
    Destination Port Range : 80 
    Click on "Save"

11. Connect using ssh (`ssh -i <private_key>  ubuntu@<public_ip_address>`).

:::
::::


## Deploy the ChatQnA Solution
Use the command below to install docker:
```bash
wget https://raw.githubusercontent.com/opea-project/GenAIExamples/refs/heads/main/ChatQnA/docker_compose/install_docker.sh
chmod +x install_docker.sh
./install_docker.sh
```
Configure Docker to run as a non-root user by following these [instructions](https://docs.docker.com/engine/install/linux-postinstall/)

Clone the repo and navigate to ChatQnA

```bash
git clone https://github.com/opea-project/GenAIExamples.git
cd GenAIExamples/ChatQnA
```
Set the required environment variables:
```bash
export host_ip="localhost"
export HUGGINGFACEHUB_API_TOKEN="Your_Huggingface_API_Token"
```

Set up other specific use-case environment variables:
```bash
cd docker_compose/intel/cpu/xeon/
source set_env.sh
```
Now we can start the services
```bash
docker compose up -d
```
>**Note**: It takes a few minutes for the services to start. Check the logs for the services to ensure that ChatQnA is running before proceeding further.

For example to check the logs for the `tgi-service`:

```bash
docker logs tgi-service | grep Connected
```
Proceed further **only after** the output shows `Connected` as shown:
```
tgi-service | 2024-10-18T22:41:18.973042Z INFO text_generation_router::server: router/src/server.rs:2311: Connected
```

Run `docker ps -a` as an additional check to verify that all the services are running as shown:

```
| CONTAINER ID | IMAGE                                                                  | COMMAND                | CREATED      | STATUS      | PORTS                                                                                    | NAMES                        |
|--------------|------------------------------------------------------------------------|------------------------|--------------|-------------|------------------------------------------------------------------------------------------|------------------------------|
| 3a65ff9e16bd | opea/nginx:latest                                                      | `/docker-entrypoint.\…`| 14 hours ago | Up 14 hours | 0.0.0.0:80->80/tcp, :::80->80/tcp                                                        | chatqna-xeon-nginx-server    |
| 7563b2ee1cd9 | opea/chatqna-ui:latest                                                 | `docker-entrypoint.s\…`| 14 hours ago | Up 14 hours | 0.0.0.0:5173->5173/tcp, :::5173->5173/tcp                                                | chatqna-xeon-ui-server       |
| 9ea57a660cd6 | opea/chatqna:latest                                                    | `python chatqna.py`    | 14 hours ago | Up 14 hours | 0.0.0.0:8888->8888/tcp, :::8888->8888/tcp                                                | chatqna-xeon-backend-server  |
| 451bacaac3e6 | opea/retriever-redis:latest                                            | `python retriever_re\…`| 14 hours ago | Up 14 hours | 0.0.0.0:7000->7000/tcp, :::7000->7000/tcp                                                | retriever-redis-server       |
| c1f952ef5c08 | opea/dataprep-redis:latest                                             | `python prepare_doc_\…`| 14 hours ago | Up 14 hours | 0.0.0.0:6007->6007/tcp, :::6007->6007/tcp                                                | dataprep-redis-server        |
| 2a874ed8ce6f | redis/redis-stack:7.2.0-v9                                             | `/entrypoint.sh`       | 14 hours ago | Up 14 hours | 0.0.0.0:6379->6379/tcp, :::6379->6379/tcp, 0.0.0.0:8001->8001/tcp, :::8001->8001/tcp     | redis-vector-db              |
| ac7b62306eb8 | ghcr.io/huggingface/text-embeddings-inference:cpu-1.5                  | `text-embeddings-rou\…`| 14 hours ago | Up 14 hours | 0.0.0.0:8808->80/tcp, [::]:8808->80/tcp                                                  | tei-reranking-server         |
| 521cc7faa00e | ghcr.io/huggingface/text-generation-inference:sha-e4201f4-intel-cpu    | `text-generation-lau\…`| 14 hours ago | Up 14 hours | 0.0.0.0:9009->80/tcp, [::]:9009->80/tcp                                                  | tgi-service                  |
| 9faf553d3939 | ghcr.io/huggingface/text-embeddings-inference:cpu-1.5                  | `text-embeddings-rou\…`| 14 hours ago | Up 14 hours | 0.0.0.0:6006->80/tcp, [::]:6006->80/tcp                                                  | tei-embedding-server         |

```

### Interact with ChatQnA

You can interact with ChatQnA via a browser interface:

* To view the ChatQnA interface, open a browser and navigate to the UI by inserting your public facing IP address in the following: `http://{public_ip}:80’.

We can go ahead and ask a sample question, say 'What is OPEA?'.

A snapshot of the interface looks as follows:

![Chat Interface](assets/chat_ui_response.png)

Given that any information about OPEA was not in the training data for the model, we see the model hallucinating and coming up with a response. We can upload a document (PDF) with information and observe how the response changes.

> **Note:** this example leverages the OPEA document for its RAG based content. You can download the [OPEA document](assets/what_is_opea.pdf) and upload it using the UI.

![Chat Interface with RAG](assets/chat_ui_response_rag.png)

We observe that the response is relevant and is based on the PDF uploaded. See the [ChatQnA Sample Guide](https://opea-project.github.io/latest/examples/ChatQnA/ChatQnA_Guide.html)
to learn how you can customize the example with your own content.

## What’s Next

- Try  [GenAIExamples](/examples/index.rst) in-detail starting with [ChatQnA](/examples/ChatQnA/ChatQnA_Guide.rst) example; this is a great example to orient yourself to the OPEA ecosystem.
- Try [GenAIComps](/microservices/index.rst) to build microservices.

### Get Involved

Have you ideas and skills to build out genAI components, microservices, and solutions? Would you like  to be a part of this  evolving technology in its early stages? Welcome!
* Register for our mailing list:
    * [Mailing List](https://lists.lfaidata.foundation/g/OPEA-announce)
    * [Technical Discussions](https://lists.lfaidata.foundation/g/OPEA-technical-discuss)
* Subscribe to the working group mailing lists that interest  you
    * [End user](https://lists.lfaidata.foundation/g/OPEA-End-User)
    * [Evaluation](https://lists.lfaidata.foundation/g/OPEA-Evaluation)
    * [Community](https://lists.lfaidata.foundation/g/OPEA-Community)
    * [Research](https://lists.lfaidata.foundation/g/OPEA-Research)
    * [Security](https://lists.lfaidata.foundation/g/OPEA-Security)
* Go to the Community Section of the OPEA repo for [Contribution Guidelines](https://opea-project.github.io/latest/community/CONTRIBUTING.html) and step by step instructions.
* Attend any of our community events and hackathons. https://wiki.lfaidata.foundation/display/DL/OPEA+Community+Events

Current GenAI Examples
- Simple chatbot that uses retrieval augmented generation (RAG) architecture. [ChatQnA](/examples/ChatQnA/ChatQnA_Guide.rst)
- Code generation, from enabling non-programmers to generate code to improving productivity with code completion of complex applications. [CodeGen](https://opea-project.github.io/latest/GenAIExamples/CodeGen/README.html)
- Make your applications more flexible by porting to different languages. [CodeTrans](https://opea-project.github.io/latest/GenAIExamples/CodeTrans/README.html)
- Create summaries of news articles, research papers, technical documents, etc. to streamline content systems. [DocSum](https://opea-project.github.io/latest/GenAIExamples/DocSum/README.html)
- Mimic human behavior by iteratively searching, selecting, and synthesizing information across large bodies of content. [SearchQnA](https://opea-project.github.io/latest/GenAIExamples/SearchQnA/README.html)
- Provide critical content to your customers by automatically generating Frequently Asked Questions (FAQ) resources. [FaqGen](https://opea-project.github.io/latest/GenAIExamples/FaqGen/README.html)
- Provide text descriptions from pictures, enabling your users to inquire directly about products, services, sites, etc. [VisualQnA](https://opea-project.github.io/latest/GenAIExamples/VisualQnA/README.html)
- Reduce language barriers through customizable text translation systems. [Translation](https://opea-project.github.io/latest/GenAIExamples/Translation/README.html)

