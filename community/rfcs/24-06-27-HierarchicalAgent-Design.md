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

 ### Part 1. 'Agent' microservice overview
  
 * Overview

   BaseAgent is an abstract class define all required properties and interfaces for Actual Agent. Different types of Agent instance can be generated according to input arguments, an app will be the only interface to process client queries and provide output.
   
   ReactAgent, PlanExecAgent, HumanInLoopAgent and etc are derived from BaseAgent with different strategies. These instances manage their own assets including prompt template, LLM endpoint, planning strategy, memory strategy and a small groups of tools provided by Users. Each agent instance is expected to work on a focused task, so the task can be performed in small amount of time with satisfied output.

   Custom Tools is a seperate input expect from User. User can use either a yaml file or fews line of python to register their own tools to agent. Yaml or python template will be listed below. 
   
    ![image](https://github.com/xuechendi/docs/assets/4355494/80614e2a-f288-4a9e-b075-4e4142688a10)

 * Expected User Input
   ```
   AGENT_NAME=finance_researcher
   strategy=react
   role=worker
   role_description="The finance_researcher is responsible for handling finance related question investigation and information collection."
   tools=/home/user/comps/agent/langchain/tools/custom_tools.yaml
   require_human_feedback=true
   llm_endpoint_url=http://xx.xx.xx.xx:8080
   llm_engine=tgi
   recursive_limit=5
   ```

   custom_tools.yaml
   ```
   google-finance:
     callable_api: google-finance
     env: SERPAPI_API_KEY=xxx
     pip_dependencies: google-search-results>=2.4.2
   propriety_info_retrieval:
     description: Retrieves the propriety information for the given entity
     callable_api: http://localhost:9090/v1/rag_retrieval
     args_schema:
       query:
         type: str
         description: Question query to get related propriety information
     return_output: propriety_info
   ticker_lookup:
     description: This function returns the ticker symbol for a stock, ETF, or an index.
     callable_api: tools/custom_tools.py:ticker_lookup
     args_schema:
       entity:
         type: str
         description: The name of the stock, ETF, or index.
     return_output: ticker_symbol
   ```

* 'Hierarchical Multi Agent' megaservice overview
  

* 'Agent' microservice tech details

* 'Hierarchical Multi Agent' megaservice tech details
