.. _DocIndexRetriever_Guide:

DocIndexRetriever
####################

.. note:: This guide is in its early development and is a work-in-progress with
   placeholder content.

Overview
********

DocIndexRetriever is the most widely adopted use case for leveraging the different 
methodologies to match user query against a set of free-text records. DocIndexRetriever 
is essential to RAG system, which bridges the knowledge gap by dynamically fetching
relevant information from external sources, ensuring that responses generated remain 
factual and current. The core of this architecture are vector databases, which are 
instrumental in enabling efficient and semantic retrieval of information. These 
databases store data as vectors, allowing RAG to swiftly access the most pertinent 
documents or data points based on semantic similarity.


Purpose
*******

* **Enable document retrieval with LLMs**: DocIndexRetriever is designed to 
  facilitate the retrieval of documents or information from a large corpus of 
  text data using Large Language Models (LLMs). 

Key Implementation Details
**************************

User Interface:
  The interface that interactivates with users, gets inputs from users and 
  serves responses to users.
DocIndexRetriever GateWay:
  The agent that maintains the connections between user-end and service-end, 
  forwards requests and responses to appropriate nodes.
DocIndexRetriever MegaService:
  The central component that converts user query to vector representation,
  retrieves relevant documents from the vector database and reranks relevant 
  documents to select the most related documents.
Data Preparation MicroService:
  The component that prepares the data for the vector database.

How It Works
************

The DocIndexRetriever example is implemented using the component-level microservices
defined in [GenAIComps](https://github.com/opea-project/GenAIComps). The flow chart 
below shows the information flow between different microservices for this example.


.. mermaid::

    ---
    config:
    flowchart:
        nodeSpacing: 400
        rankSpacing: 100
        curve: linear
    themeVariables:
        fontSize: 50px
    ---
    flowchart LR
        %% Colors %%
        classDef blue fill:#ADD8E6,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
        classDef orange fill:#FBAA60,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
        classDef orchid fill:#C26DBC,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
        classDef invisible fill:transparent,stroke:transparent;
        style DocIndexRetriever-MegaService stroke:#000000

        %% Subgraphs %%
        subgraph DocIndexRetriever-MegaService["DocIndexRetriever MegaService "]
            direction LR
            EM([Embedding MicroService]):::blue
            RET([Retrieval MicroService]):::blue
            RER([Rerank MicroService]):::blue
        end
        subgraph UserInput[" User Input "]
            direction LR
            a([User Input Query]):::orchid
            Ingest([Ingest data]):::orchid
        end

        DP([Data Preparation MicroService]):::blue
        TEI_RER{{Reranking service<br>}}
        TEI_EM{{Embedding service <br>}}
        VDB{{Vector DB<br><br>}}
        R_RET{{Retriever service <br>}}
        GW([DocIndexRetriever GateWay<br>]):::orange

        %% Data Preparation flow
        %% Ingest data flow
        direction LR
        Ingest[Ingest data] --> DP
        DP <-.-> TEI_EM

        %% Questions interaction
        direction LR
        a[User Input Query] --> GW
        GW <==> DocIndexRetriever-MegaService
        EM ==> RET
        RET ==> RER

        %% Embedding service flow
        direction LR
        EM <-.-> TEI_EM
        RET <-.-> R_RET
        RER <-.-> TEI_RER

        direction TB
        %% Vector DB interaction
        R_RET <-.-> VDB
        DP <-.-> VDB


This diagram illustrates the flow of information in the DocIndexRetriever system. 
Firstly, the user provides docments to the system, which are ingested by the
Data Preparation MicroService. The Data Preparation MicroService prepares the data
for the vector database. The User Input Query is then sent to the DocIndexRetriever
Gateway, which forwards the query to the DocIndexRetriever MegaService. The
DocIndexRetriever MegaService uses the Embedding MicroService to convert the query
to a vector representation. The Retrieval MicroService retrieves relevant documents
from the vector database, and the Rerank MicroService reranks the relevant documents
to select the most related documents. The reranked documents are then sent back to
the DocIndexRetriever Gateway, which forwards the documents to the user.


The architecture follows a series of steps to process user queries and generate 
responses:

1. **Embedding**: The Embedding MicroService converts the user query into a vector 
   representation.
#. **Retriever**: The Retrieval MicroService retrieves relevant documents from the 
   vector database based on the vector representation of the user query.
#. **Reranker**: The Rerank MicroService reranks the relevant documents to select 
   the most related documents.
#. **Vector Database**: The Vector Database stores data as vectors, allowing the 
   system to swiftly access the most pertinent documents or data points based on 
   semantic similarity.
#. **Data Preparation**: The Data Preparation MicroService prepares the data for the 
   vector database.

Deployment
**********

Here are some deployment options depending on your hardware and environment.

Single Node
+++++++++++++++
.. toctree::
   :maxdepth: 1

   Xeon Scalable Processor <deploy/xeon>
   Gaudi <deploy/gaudi>
