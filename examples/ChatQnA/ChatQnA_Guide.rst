.. _ChatQnA_Guide:

ChatQnA Sample Guide
####################

Introduction/Purpose
*********************

Overview/Intro
==============

Purpose
=======

AI Catalog Preview 
==================

(if applicable)

Key Implementation Details 
==========================

Tech overview
*************

How it works
============

Expected Output
===============

Customization
==============

Validation Matrix and Prerequisites
***********************************

Architecture
************

Need to include the architecture with microservices. Like the ones Xigui/Chun made and explain in a para or 2 on the highlights of the arch including Gateway, UI, mega service, how models are deployed and how the microservices use the deployment service. The architecture can be laid out as general as possible, maybe  calling out “for e.g” on variable pieces. Will also be good to include a linw or 2 on what the overall use case is. For e.g. This chatqna is setup to assist in ansewering question on OPEA. The microservices are set up with RAG and llm pipeline to query on OPEA pdf documents 

Microservice outline and diagram
================================

Deployment
**********

.. tabs::

   .. tab:: Single Node deployment

      (IDC or on prem metal: Xeon, Gaudi, AI PC, Nvidia?)

   .. tab:: Kubernetes 

      K8S for Clusters.

   .. tab:: Cloud Deployment

      AWS and Azure.

   .. tab:: Managed Services Deployment

      Such as..

Troubleshooting
***************

Monitoring 
**********

Evaluate performance and accuracy

Summary and Next Steps
**********************