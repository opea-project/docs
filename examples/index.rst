.. _GenAIExamples:

GenAI Examples
##############

GenAIExamples are designed to give developers an easy entry into generative AI, featuring microservice-based samples that simplify the processes of deploying, testing, and scaling GenAI applications. All examples are fully compatible with Docker and Kubernetes, supporting a wide range of hardware platforms such as Gaudi, Xeon, and NVIDIA GPU, and other hardware, ensuring flexibility and efficiency for your GenAI adoption.

.. toctree::
   :maxdepth: 1

   ChatQnA/ChatQnA_Guide
   ChatQnA/deploy/index

----

We're building this documentation from content in the
:GenAIExamples_blob:`GenAIExamples<README.md>` GitHub repository.

.. rst-class:: rst-columns

.. toctree::
   :maxdepth: 1
   :glob:

   /GenAIExamples/README
   /GenAIExamples/*

**Example Applications Table of Contents**

.. rst-class:: rst-columns

.. contents::
   :local:
   :depth: 1

----

.. comment This include file is generated in the Makefile during doc build
   time from all the directories found in the GenAIExamples top level directory

.. include:: examples.txt
