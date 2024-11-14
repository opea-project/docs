.. _AgentQnA_Guide:

AgentQnA Sample Guide
#####################

.. note:: This guide is in its early development and is a work-in-progress with
   placeholder content.

Overview
********

This example showcases a hierarchical multi-agent system for question-answering applications. 

Purpose
*******
* Improve relevancy of retrieved context. Agent can rephrase user queries, decompose user queries, and iterate to get the most relevant context for answering user’s questions. Compared to conventional RAG, RAG agent can significantly improve the correctness and relevancy of the answer.
* Use tools to get additional knowledge. For example, knowledge graphs and SQL databases can be exposed as APIs for Agents to gather knowledge that may be missing in the retrieval vector database.
* Hierarchical agent can further improve performance. Expert worker agents, such as retrieval agent, knowledge graph agent, SQL agent, etc., can provide high-quality output for different aspects of a complex query, and the supervisor agent can aggregate the information together to provide a comprehensive answer.

How It Works
************

The supervisor agent interfaces with the user and dispatch tasks to the worker agent and other tools to gather information and come up with answers.
The worker agent uses the retrieval tool to generate answers to the queries posted by the supervisor agent.


.. mermaid::

   graph LR;
      U[User]-->SA[Supervisor Agent];
      SA-->WA[Worker Agent];
      WA-->RT[Retrieval Tool];
      SA-->T1[Tool 1];
      SA-->T2[Tool 2];
      SA-->TN[Tool N];
      SA-->U;
      WA-->SA;
      RT-->WA;
      T1-->SA;
      T2-->SA;
      TN-->SA;


Deployment
**********

See the :ref:`agentqna-example-deployment`.