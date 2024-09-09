.. _ChatQnA_Guide:

ChatQnA Sample Guide
####################

.. note:: This guide is in its early development and is a work-in-progress with
   placeholder content.

Introduction/Purpose
********************

TODO: Tom to provide.

Overview/Intro
==============

Chatbots are a  widely adopted use case for leveraging the powerful chat and
reasoning capabilities of large language models (LLMs).  The ChatQnA example
provides the starting point for developers to begin working in the GenAI space.
Consider it the “hello world” of GenAI applications and can be leveraged for
solutions across wide enterprise verticals, both internally and externally.

Purpose
=======

The ChatQnA example uses retrieval augmented generation (RAG) architecture,
which is quickly becoming the industry standard for chatbot development. It
combines the benefits of a knowledge base (via a vector store) and generative
models to reduce hallucinations, maintain up-to-date information, and leverage
domain-specific knowledge.

RAG bridges the knowledge gap by dynamically fetching relevant information from
external sources, ensuring that responses generated remain factual and current.
The core of this architecture are vector databases, which are instrumental in
enabling efficient and semantic retrieval of information. These databases store
data as vectors, allowing RAG to swiftly access the most pertinent documents or
data points based on semantic similarity.

Central to the RAG architecture is the use of a generative model, which is
responsible for generating responses to user queries. The generative model is
trained on a large corpus of customized and relevant text data and is capable of
generating human-like responses. Developers can easily swap out the generative
model or vector database with their own custom models or databases. This allows
developers to build chatbots that are tailored to their specific use cases and
requirements. By combining the generative model with the vector database, RAG
can provide accurate and contextually relevant responses specific to your users'
queries.

The ChatQnA example is designed to be a simple, yet powerful, demonstration of
the RAG architecture. It is a great starting point for developers looking to
build chatbots that can provide accurate and up-to-date information to users.

GMC is GenAI Microservices Connector. GMC facilitates sharing of services across
GenAI applications/pipelines, dynamic switching between models used in any stage
of a GenAI pipeline, for instance in the ChatQnA GenAI pipeline, it supports
changing the model used in the embedder, re-ranker, and/or the LLM.

So one can use Upstream Vanilla Kubernetes or RHOCP, and one can use them with
and without GMC. GMC as indicated provides additional features.

The ChatQnA provides several deployment options, including single-node
deployments on-premise or in a cloud environment using hardware such as Xeon
Scalable Processors, Gaudi servers, NVIDIA GPUs, and even on AI PCs.  It also
supports Kubernetes deployments with and without the GenAI Management Console
(GMC), as well as cloud-native deployments using Red Hat OpenShift Container
Platform (RHOCP).


Preview
=======

To get a preview of the ChatQnA example, visit the
`AI Explore site <https://aiexplorer.intel.com/explore>`_. The **ChatQnA Solution**
provides a basic chatbot while the **ChatQnA with Augmented Context**
allows you to upload your own files in order to quickly experiment with a RAG
solution to see how a developer supplied corpus can provide relevant and up to
date responses.

Key Implementation Details
==========================

Embedding:
  The process of transforming user queries into numerical representations called
  embeddings.
Vector Database:
  The storage and retrieval of relevant data points using vector databases.
RAG Architecture:
  The use of the RAG architecture to combine knowledge bases and generative
  models for development of chatbots with relevant and up to date query
  responses.
Large Language Models (LLMs):
  The training and utilization of LLMs for generating responses.
Deployment Options:
  production ready deployment options for the ChatQnA
  example, including single-node deployments and Kubernetes deployments.

How It Works
============

The ChatQnA Examples follows a basic flow of information in the chatbot system,
starting from the user input and going through the retrieve, re-ranker, and
generate components, ultimately resulting in the bot's output.

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_architecture.png
   :alt: ChatQnA Architecture Diagram

   This diagram illustrates the flow of information in the chatbot system,
   starting from the user input and going through the retrieve, analyze, and
   generate components, ultimately resulting in the bot's output.

The architecture follows a series of steps to process user queries and generate responses:

1. **Embedding**: The user query is first transformed into a numerical
   representation called an embedding. This embedding captures the semantic
   meaning of the query and allows for efficient comparison with other
   embeddings.
#. **Vector Database**: The embedding is then used to search a vector database,
   which stores relevant data points as vectors. The vector database enables
   efficient and semantic retrieval of information based on the similarity
   between the query embedding and the stored vectors.
#. **Re-ranker**: Uses a model to rank the retrieved data on their saliency.
   The vector database retrieves the most relevant data
   points based on the query embedding. These data points can include documents,
   articles, or any other relevant information that can help generate accurate
   responses.
#. **LLM**: The retrieved data points are then passed to large language models
   (LLM) for further processing. LLMs are powerful generative models that have
   been trained on a large corpus of text data. They can generate human-like
   responses based on the input data.
#. **Generate Response**: The LLMs generate a response based on the input data
   and the user query. This response is then returned to the user as the
   chatbot's answer.

Expected Output
===============

Validation Matrix and Prerequisites
***********************************

See :doc:`/GenAIExamples/supported_examples`

Architecture
************

TODO: Includes microservice level graphics.

TODO: Need to include the architecture with microservices. Like the ones
Xigui/Chun made and explain in a paragraph or 2 on the highlights of the arch
including Gateway, UI, mega service, how models are deployed and how the
microservices use the deployment service. The architecture can be laid out as
general as possible, maybe  calling out “for e.g” on variable pieces. Will also
be good to include a line or 2 on what the overall use case is. For e.g. This
chatqna is setup to assist in answering question on OPEA. The microservices are
set up with RAG and LLM pipeline to query on OPEA PDF documents

Microservice Outline and Diagram
================================

Deployment
**********


Single Node
===========

.. toctree::
   :maxdepth: 1

   deploy/xeon
   deploy/gaudi
   deploy/nvidia
   deploy/AIPC

Kubernetes
==========

* Xeon & Gaudi with GMC
* Xeon & Gaudi without GMC
* Using Helm Charts

Cloud Native
============

* Red Hat OpenShift Container Platform (RHOCP)

Troubleshooting
***************

Monitoring
**********

Evaluate performance and accuracy

Summary and Next Steps
**********************
