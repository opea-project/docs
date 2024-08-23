.. _ChatQnA_Guide:

ChatQnA Sample Guide
####################

Introduction/Purpose
********************

Tom to provide. 

Overview/Intro
==============

Purpose
=======

Preview 
=======

AI catalog if applicable, or recorded demos. 

Key Implementation Details 
==========================

Tech Overview
*************

How It Works
============

High level graphics to summarize the application.

Expected Output
===============

Validation Matrix and Prerequisites
***********************************

Architecture
************

Includes microservice level graphics.

Need to include the architecture with microservices. Like the ones Xigui/Chun made and explain in a para or 2 on the highlights of the arch including Gateway, UI, mega service, how models are deployed and how the microservices use the deployment service. The architecture can be laid out as general as possible, maybe  calling out “for e.g” on variable pieces. Will also be good to include a linw or 2 on what the overall use case is. For e.g. This chatqna is setup to assist in ansewering question on OPEA. The microservices are set up with RAG and llm pipeline to query on OPEA pdf documents 

Microservice Outline and Diagram
================================

Deployment
**********

+--------------------------------------------=-----------------------------------------+
| Single Node                                                                          |
|                                                                                      |
+============================================+=========================================+
| XEON Scalable Processors                   |Gaudi Servers                            |
|                                            |                                         |
+--------------------------------------------+-----------------------------------------+
| NNIDIA GPUs                                | AI PC                                   |
|                                            |                                         |
+--------------------------------------------+-----------------------------------------+

+--------------------------------------------=-----------------------------------------+
| Kubernetes                                                                           |
|                                                                                      |
+============================================+=========================================+
| Xeon & Gaudi with GMC                      |Xeon & Gaudi without GMC                 |
|                                            |                                         |
+--------------------------------------------+-----------------------------------------+
| Using Helm Charts                          |                                         |
|                                            |                                         |
+--------------------------------------------+-----------------------------------------+

+--------------------------------------------=-----------------------------------------+
|Cloud Native                                                                          |
|                                                                                      |
+============================================+=========================================+
| Red Hat OpenShift Container Platform       |                                         |
| (RHOCP)                                    |                                         |
+--------------------------------------------+-----------------------------------------+

Troubleshooting
***************

Monitoring 
**********

Evaluate performance and accuracy

Summary and Next Steps
**********************