**Author**

[Chendi Xue](http://github.com/xuechendi) [Minmin Hou](https://github.com/minmin-intel/)

**Status**

Under Review

**Objective**

This RFC introduces a new concept of an "Hierarchical Agent," which includes two parts.
* 'Agent' microservice: Agent refers to a framework that integrates the reasoning capabilities of large language models (LLMs) with the ability to take actionable steps, creating a more sophisticated system that can understand and process information, evaluate situations, take appropriate actions, communicate responses, and track ongoing situations, Finally output with result meeting defined goals.

* 'Hierarchical Multi Agent' megaservice: Multi Agents refer to a design that leveraging a Hierarchical Agent Teams to complete sub-tasks through individual agent working groups. Benefits of multi-agents design: (1) Grouping tools/responsibilities can give better results. An agent is more likely to succeed on a focused task than if it has to select from dozens of tools. (2) Each agent will have their own assets including prompt, llm model, planning strategy and toolsets. (3) User can easily using yaml files or fews lines of python to build a 'Hierarchical Multi Agent' megaservice by cherry-picking ready-to-use individual agents. (4) For small tasks which can be perfectly performed by single Agent, user can directly use 'Agent' microservice with simple/easy resource management.

**Motivation**
This RFC aims to provide agents as new microservice / megaservice for Enterprise users who is looking for using their own tools with LLM. Tools can be not limited as domain specific search, knowledgebase retrieval, enterprise service api(need special authorization), proprietary tools, etc.


**Design Proposal**
kajs