**Author**

[Chendi Xue](http://github.com/xuechendi) [Minmin Hou](https://github.com/minmin-intel/)

**Status**

Under Review

**Objective**

This RFC introduces a new concept of an "Hierarchical Agent," which includes two parts.
* 'Agent' microservice: Agent refers to a framework that integrates the reasoning capabilities of large language models (LLMs) with the ability to take actionable steps, creating a more sophisticated system that can understand and process information, evaluate situations, take appropriate actions, communicate responses, and track ongoing situations, Finally output with result meeting defined goals.

* 'Hierarchical Multi Agent' megaservice: Multi Agents refer to a design that leveraging a Hierarchical Agent Teams to complete sub-tasks through individual agent working groups. Benefits of multi-agents design: (1) Grouping tools/responsibilities can give better results. An agent is more likely to succeed on a focused task than if it has to select from dozens of tools. (2) Each agent will have their own assets including prompt, llm model, planning strategy and toolsets. (3) User can easily using yaml files or fews lines of python to build a 'Hierarchical Multi Agent' megaservice by cherry-picking ready-to-use individual agents. (4) For small tasks which can be perfectly performed by single Agent, user can directly use 'Agent' microservice with simple/easy resource management.

**Motivation**

This RFC aims to provide agents as new microservice / megaservice for Enterprise users who are looking for using their own tools with LLM. Tools includes __domain_specific_search__, __knowledgebase_retrieval__, __enterprise_servic_api_authorization_required__, __proprietary_tools__, etc.


**Design Proposal**

  * 'Agent' microservice overview
  
    ![image](https://github.com/xuechendi/docs/assets/4355494/80614e2a-f288-4a9e-b075-4e4142688a10)

    Expected User Input

    ![image](https://github.com/xuechendi/docs/assets/4355494/53412d4c-e8dd-4516-87c5-a412a9299207)




* 'Hierarchical Multi Agent' megaservice overview
  

* 'Agent' microservice tech details

* 'Hierarchical Multi Agent' megaservice tech details
