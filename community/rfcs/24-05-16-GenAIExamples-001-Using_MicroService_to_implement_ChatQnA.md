# 24-05-16 GenAIExamples-001 Using MicroService to Implement ChatQnA

## Author
[lvliang-intel](https://github.com/lvliang-intel), [ftian1](https://github.com/ftian1), [hshen14](https://github.com/hshen14), [Spycsh](https://github.com/Spycsh), [letonghan](https://github.com/letonghan)

## Status
Under Review

## Objective
This RFC aims to introduce the OPEA microservice design and demonstrate its application to Retrieval-Augmented Generation (RAG). The objective is to address the challenge of designing a flexible architecture for Enterprise AI applications by adopting a microservice approach. This approach facilitates easier deployment, enabling one or multiple microservices to form a megaservice. Each megaservice interfaces with a gateway, allowing users to access services through endpoints exposed by the gateway. The architecture is general and RAG is the first example that we want to apply.


## Motivation
In designing the Enterprise AI applications, leveraging a microservices architecture offers significant advantages, particularly in handling large volumes of user requests. By breaking down the system into modular microservices, each dedicated to a specific function, we can achieve substantial performance improvements through the ability to scale out individual components. This scalability ensures that the system can efficiently manage high demand, distributing the load across multiple instances of each microservice as needed.

The microservices architecture contrasts sharply with monolithic approaches, such as the tightly coupled module structure found in LangChain. In such monolithic designs, all modules are interdependent, posing significant deployment challenges and limiting scalability. Any change or scaling requirement in one module necessitates redeploying the entire system, leading to potential downtime and increased complexity.


## Design Proposal

### Microservice

Microservices are akin to building blocks, offering the fundamental services for constructing RAG (Retrieval-Augmented Generation) applications. Each microservice is designed to perform a specific function or task within the application architecture. By breaking down the system into smaller, self-contained services, microservices promote modularity, flexibility, and scalability. This modular approach allows developers to independently develop, deploy, and scale individual components of the application, making it easier to maintain and evolve over time. Additionally, microservices facilitate fault isolation, as issues in one service are less likely to impact the entire system.

### Megaservice

A megaservice is a higher-level architectural construct composed of one or more microservices, providing the capability to assemble end-to-end applications. Unlike individual microservices, which focus on specific tasks or functions, a megaservice orchestrates multiple microservices to deliver a comprehensive solution. Megaservices encapsulate complex business logic and workflow orchestration, coordinating the interactions between various microservices to fulfill specific application requirements. This approach enables the creation of modular yet integrated applications, where each microservice contributes to the overall functionality of the megaservice.

### Gateway

The Gateway serves as the interface for users to access the megaservice, providing customized access based on user requirements. It acts as the entry point for incoming requests, routing them to the appropriate microservices within the megaservice architecture. Gateways support API definition, API versioning, rate limiting, and request transformation, allowing for fine-grained control over how users interact with the underlying microservices. By abstracting the complexity of the underlying infrastructure, gateways provide a seamless and user-friendly experience for interacting with the megaservice.


### Proposal
The proposed architecture for the ChatQnA application involves the creation of two megaservices. The first megaservice functions as the core pipeline, comprising four microservices: embedding, retriever, reranking, and LLM. This megaservice exposes a ChatQnAGateway, allowing users to query the system via the `/v1/chatqna` endpoint. The second megaservice manages user data storage in VectorStore and is composed of a single microservice, dataprep. This megaservice provides a DataprepGateway, enabling user access through the `/v1/dataprep` endpoint.

The Gateway class facilitates the registration of additional endpoints, enhancing the system's flexibility and extensibility. The /v1/dataprep endpoint is responsible for handling user documents to be stored in VectorStore under a predefined database name. The first megaservice will then query the data from this predefined database.

![architecture](https://i.imgur.com/YdsXy46.png)


#### Example Python Code for Constructing Services

Users can use `ServiceOrchestrator` class to build the microservice pipeline and add a gateway for each megaservice.

```python
class ChatQnAService:
    def __init__(self, rag_port=8888, data_port=9999):
        self.rag_port = rag_port
        self.data_port = data_port
        self.rag_service = ServiceOrchestrator()
        self.data_service = ServiceOrchestrator()

    def construct_rag_service(self):
        embedding = MicroService(
            name="embedding",
            host=SERVICE_HOST_IP,
            port=6000,
            endpoint="/v1/embeddings",
            use_remote_service=True,
            service_type=ServiceType.EMBEDDING,
        )
        retriever = MicroService(
            name="retriever",
            host=SERVICE_HOST_IP,
            port=7000,
            endpoint="/v1/retrieval",
            use_remote_service=True,
            service_type=ServiceType.RETRIEVER,
        )
        rerank = MicroService(
            name="rerank",
            host=SERVICE_HOST_IP,
            port=8000,
            endpoint="/v1/reranking",
            use_remote_service=True,
            service_type=ServiceType.RERANK,
        )
        llm = MicroService(
            name="llm",
            host=SERVICE_HOST_IP,
            port=9000,
            endpoint="/v1/chat/completions",
            use_remote_service=True,
            service_type=ServiceType.LLM,
        )
        self.rag_service.add(embedding).add(retriever).add(rerank).add(llm)
        self.rag_service.flow_to(embedding, retriever)
        self.rag_service.flow_to(retriever, rerank)
        self.rag_service.flow_to(rerank, llm)
        self.rag_gateway = ChatQnAGateway(megaservice=self.rag_service, host="0.0.0.0", port=self.rag_port)

    def construct_data_service(self):
        dataprep = MicroService(
            name="dataprep",
            host=SERVICE_HOST_IP,
            port=5000,
            endpoint="/v1/dataprep",
            use_remote_service=True,
            service_type=ServiceType.DATAPREP,
        )
        self.data_service.add(dataprep)
        self.data_gateway = DataPrepGateway(megaservice=self.data_service, host="0.0.0.0", port=self.data_port)

    def start_service(self):
        self.construct_rag_service()
        self.construct_data_service()
        self.rag_gateway.start()
        self.data_gateway.start()

if __name__ == "__main__":
    chatqna = ChatQnAService()
    chatqna.start_service()
```

#### Constructing Services with yaml

Below is an example of how to define microservices and megaservices using YAML for the ChatQnA application. This configuration outlines the endpoints for each microservice and specifies the workflow for the megaservices.

```yaml
opea_micro_services:
  dataprep:
    endpoint: http://localhost:5000/v1/chat/completions
  embedding:
    endpoint: http://localhost:6000/v1/embeddings
  retrieval:
    endpoint: http://localhost:7000/v1/retrieval
  reranking:
    endpoint: http://localhost:8000/v1/reranking
  llm:
    endpoint: http://localhost:9000/v1/chat/completions

opea_mega_service:
  mega_flow:
    - embedding >> retrieval >> reranking >> llm
  dataprep:
    mega_flow:
        - dataprep
```

```yaml
opea_micro_services:
  dataprep:
    endpoint: http://localhost:5000/v1/chat/completions

opea_mega_service:
  mega_flow:
    - dataprep
```

The following Python code demonstrates how to use the YAML configurations to initialize the microservices and megaservices, and set up the gateways for user interaction.

```python
from comps import ServiceOrchestratorWithYaml
from comps import ChatQnAGateway, DataPrepGateway
data_service = ServiceOrchestratorWithYaml(yaml_file_path="dataprep.yaml")
rag_service = ServiceOrchestratorWithYaml(yaml_file_path="rag.yaml")
rag_gateway = ChatQnAGateway(data_service, port=8888)
data_gateway = DataPrepGateway(data_service, port=9999)
# Start gateways
rag_gateway.start()
data_gateway.start()
```

#### Example Code for Customizing Gateway

The Gateway class provides a customizable interface for accessing the megaservice. It handles requests and responses, allowing users to interact with the megaservice. The class defines methods for adding custom routes, stopping the service, and listing available services and parameters. Users can extend this class to implement specific handling for requests and responses according to their requirements.

```python
class Gateway:
    def __init__(
        self,
        megaservice,
        host="0.0.0.0",
        port=8888,
        endpoint=str(MegaServiceEndpoint.CHAT_QNA),
        input_datatype=ChatCompletionRequest,
        output_datatype=ChatCompletionResponse,
    ):
        ...
        self.gateway = MicroService(
            service_role=ServiceRoleType.MEGASERVICE,
            service_type=ServiceType.GATEWAY,
            ...
        )
        self.define_default_routes()

    def define_default_routes(self):
        self.service.app.router.add_api_route(self.endpoint, self.handle_request, methods=["POST"])
        self.service.app.router.add_api_route(str(MegaServiceEndpoint.LIST_SERVICE), self.list_service, methods=["GET"])
        self.service.app.router.add_api_route(
            str(MegaServiceEndpoint.LIST_PARAMETERS), self.list_parameter, methods=["GET"]
        )

    def add_route(self, endpoint, handler, methods=["POST"]):
        self.service.app.router.add_api_route(endpoint, handler, methods=methods)

    def start(self):
        self.gateway.start()

    def stop(self):
        self.gateway.stop()

    async def handle_request(self, request: Request):
        raise NotImplementedError("Subclasses must implement this method")

    def list_service(self):
        raise NotImplementedError("Subclasses must implement this method")

    def list_parameter(self):
        raise NotImplementedError("Subclasses must implement this method")

    ...
```

## Alternatives Considered
An alternative approach could be to design a monolithic application for RAG instead of a microservice architecture. However, this approach may lack the flexibility and scalability offered by microservices. Pros of the proposed microservice architecture include easier deployment, independent scaling of components, and improved fault isolation. Cons may include increased complexity in managing multiple services.

## Compatibility
Potential incompatible interface or workflow changes may include adjustments needed for existing clients to interact with the new microservice architecture. However, careful planning and communication can mitigate any disruptions.

## Miscs
Performance Impact: The microservice architecture may impact performance metrics, depending on factors such as network latency. But for large-scale user access, scaling out microservices can enhance responsiveness, thereby significantly improving performance compared to monolithic designs.

By adopting this microservice architecture for RAG, we aim to enhance the flexibility, scalability, and maintainability of the Enterprise AI application deployment, ultimately improving the user experience and facilitating future development and enhancements.

