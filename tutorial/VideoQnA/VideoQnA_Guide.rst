.. _VideoQnA_Guide:

VideoQnA
#################

.. note:: This guide is in its early development and is a work-in-progress with
   placeholder content.

Overview
********

VideoQnA is a framework that retrieves video based on provided user prompt. It uses only the video embeddings to perform vector similarity search in Intel's VDMS vector database and performs all operations on Intel Xeon CPU. The pipeline supports long form videos and time-based search.

Purpose
*******

* Efficient Search: Utilizes video embeddings for accurate and efficient retrieval.
* Long-form Video Support: Capable of handling extensive video archives and time-based searches.
* Microservice Architecture: Built on GenAIComps, incorporating microservices for embedding, retrieval, reranking, and language model integration.

How It Works
************

It utilizes the `GenAIComps <https://github.com/opea-project/GenAIComps>`_ microservice pipeline on Intel Xeon server. The steps include Docker image creation, container deployment via Docker Compose, and service execution to integrate microservices such as embedding, retriever, rerank, and lvm. Videos are converted into feature vectors using mean aggregation and stored in the VDMS vector store. When a user submits a query, the system performs a similarity search in the vector store to retrieve the best-matching videos. Contextual Inference: The retrieved videos are then sent to the Large Vision Model (LVM) for inference, providing supplemental context for the query.

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
       style VideoQnA-MegaService stroke:#000000
       %% Subgraphs %%
       subgraph VideoQnA-MegaService["VideoQnA-MegaService"]
           direction LR
           EM([Embedding MicroService]):::blue
           RET([Retrieval MicroService]):::blue
           RER([Rerank MicroService]):::blue
           LVM([LVM MicroService]):::blue
       end
       subgraph User Interface
           direction LR
           a([User Input Query]):::orchid
           UI([UI server<br>]):::orchid
           Ingest([Ingest<br>]):::orchid
       end

       LOCAL_RER{{Reranking service<br>}}
       CLIP_EM{{Embedding service <br>}}
       VDB{{Vector DB<br><br>}}
       V_RET{{Retriever service <br>}}
       Ingest{{Ingest data <br>}}
       DP([Data Preparation<br>]):::blue
       LVM_gen{{LVM Service <br>}}
       GW([VideoQnA GateWay<br>]):::orange

       %% Data Preparation flow
       %% Ingest data flow
       direction LR
       Ingest[Ingest data] --> UI
       UI --> DP
       DP <-.-> CLIP_EM

       %% Questions interaction
       direction LR
       a[User Input Query] --> UI
       UI --> GW
       GW <==> VideoQnA-MegaService
       EM ==> RET
       RET ==> RER
       RER ==> LVM

       %% Embedding service flow
       direction LR
       EM <-.-> CLIP_EM
       RET <-.-> V_RET
       RER <-.-> LOCAL_RER
       LVM <-.-> LVM_gen

       direction TB
       %% Vector DB interaction
       V_RET <-.->VDB
       DP <-.->VDB

Deployment
**********

To deploy on Xeon, please check guide `here <https://opea-project.github.io/latest/GenAIExamples/VideoQnA/docker_compose/intel/cpu/xeon/README.html>`_









