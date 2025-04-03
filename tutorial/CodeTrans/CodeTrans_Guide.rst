.. _CodeTrans_Guide:

Code Translations
##############################

.. note:: This guide is in its early development and is a work-in-progress with
   placeholder content.

Overview
********

This example showcases a code translation system that converts code from one programming language to another while preserving the original logic and functionality. The primary component is the CodeTrans MegaService, which encompasses an LLM microservice that performs the actual translation.
A lightweight Gateway service and a User Interface allow users to submit their source code in a given language and receive the translated output in another language.

Purpose
*******
* **Enable code conversion and modernization**: Developers can seamlessly migrate legacy code to newer languages or frameworks, leveraging modern best practices without having to rewrite large code bases from scratch.

* **Facilitate multi-language support**: By providing a system that understands multiple programming languages, organizations can unify their development approaches and reduce the barrier to adopting new languages.

* **Improve developer productivity**: Automated code translation drastically reduces manual, time-consuming porting efforts, allowing developers to focus on higher-level tasks like feature design and optimization.

How It Works
************

.. figure:: /GenAIExamples/CodeTrans/assets/img/code_trans_architecture.png
   :alt: ChatQnA Architecture Diagram

1. A user specifies the source language, the target language, and the snippet of code to be translated. This request is handled by the front-end UI or via a direct API call.


2. The user’s request is sent to the CodeTrans Gateway, which orchestrates the call to the LLM MicroService. The gateway handles details like constructing prompts and managing responses.


3. The large language model processes the user’s code snippet, analyzing syntax and semantics before generating an equivalent snippet in the target language.

4. The gateway formats the model’s output and returns the translated code to the user, either via an API response or rendered within the UI.


Deployment
**********
Here are some deployment options, depending on your hardware and environment:

Single Node
+++++++++++++++
.. toctree::
   :maxdepth: 1

   Xeon Scalable Processor <deploy/xeon>
   Gaudi <deploy/gaudi>
