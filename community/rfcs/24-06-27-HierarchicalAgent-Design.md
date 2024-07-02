**Author**

[Chendi Xue](http://github.com/xuechendi) [Minmin Hou](https://github.com/minmin-intel/)

**Status**

Under Review

## Objective

This RFC introduces a new concept of an "Hierarchical Agent," which includes two parts.

* 'Agent' microservice: Agent refers to a framework that integrates the reasoning capabilities of large language models (LLMs) with the ability to take actionable steps, creating a more sophisticated system that can understand and process information, evaluate situations, take appropriate actions, communicate responses, and track ongoing situations, Finally output with result meeting defined goals.

* 'Hierarchical Multi Agent' system: Multi Agents refer to a design that leveraging a Hierarchical Agent Teams to complete sub-tasks through individual agent working groups. Benefits of multi-agents design: (1) Grouping tools/responsibilities can give better results. An agent is more likely to succeed on a focused task than if it has to select from dozens of tools. (2) Each agent will have their own assets including prompt, llm model, planning strategy and toolsets. (3) User can easily using yaml files or fews lines of python to build a 'Hierarchical Multi Agent' megaservice by cherry-picking ready-to-use individual agents. (4) For small tasks which can be perfectly performed by single Agent, user can directly use 'Agent' microservice with simple/easy resource management.

## Motivation

This RFC aims to provide __low-code / no-code__ agents as new microservice / megaservice for Enterprise users who are looking for using their own tools with LLM. Tools includes __domain_specific_search__, __knowledgebase_retrieval__, __enterprise_servic_api_authorization_required__, __proprietary_tools__, etc.

## Persona

We use the listed terms to define different persona mentioned in this document. 

  * OPEA developer: Only persona who is required to rebuild agent docker image. OPEA developer develops OPEA agent codes and add new Agent Implementation by extending current Agent library with advanced agent strategies.
  * Enterprise User: This persona required to launch docker service and need to provide small blocks of python codes or yaml configuration to config OPEA microservice / megaservice. They are also expected to follow customer_tool template to provide theirown tools and register to Agent microservice.
  * End user: This persona only interact with Agent API by sending queries. Queries can be plain text, files, or json format data with richer information.

## Design Proposal

 ### Part 1. 'Agent' microservice overview
  
 * Overview

   BaseAgent is an abstract class define all required properties and interfaces for Actual Agent. Different types of Agent instance can be generated according to input arguments, an app will be the only interface to process client queries and provide output.
   
   ReactAgent, PlanExecAgent, HumanInLoopAgent and etc are derived from BaseAgent with different strategies. These instances manage their own assets including prompt template, LLM endpoint, planning strategy, memory strategy and a small groups of tools provided by Users. Each agent instance is expected to work on a focused task, so the task can be performed in small amount of time with satisfied output.

   Custom Tools is a seperate input expect from User. User can use either a yaml file or fews line of python to register their own tools to agent. Yaml or python template will be listed below.

    ![image](https://github.com/xuechendi/docs/assets/4355494/80614e2a-f288-4a9e-b075-4e4142688a10)

* Expected from End User

  Use exposed to http API to interact with entry Agent. query can be in format as plain text, json format text or files.

  ![image](https://github.com/xuechendi/docs/assets/4355494/41a40edc-df73-4e3d-8b0a-c206724cc881)

  behind the scene

  ![image](https://github.com/xuechendi/docs/assets/4355494/02232f5b-8034-44f9-a10c-545a13ec5e40)

* Expected from Enterprise User

   Follow pre-defined keywords to provide required system enviroment and tool configuration

   __example__ Agent Configuration (expected from Enterprise USER)
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

    __example__ custom_tools.yaml (expected from Enterprise USER)
   ``` custom_tools.yaml
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

 * Expected from OPEA developer

   Define new Agent follow below template to include improved strategy, prompt, memory

   __example__ Define a New Agent IMPLEMENTATION (expected from OPEA developer)
   ``` python
   class PlanExecuteAgent(BaseAgent):
       def __init__(self, args):
           super().__init__(args)
           from .planexec.planner import create_planner   
           self.planner = create_planner(args, self.llm_endpoint, self.tools_descriptions, memory=self.memory, planner_type="initial_plan")
           self.plan_rewriter = ...
           self.replanner = ...   
           self.app = self.compile_workflow()   
           # app will be returned as only interface for query handling
   ```


### Part2. 'Hierarchical Multi Agent' system overview

  * Overview

    supervisorAgent, WorkerAgent are all launched 'Agent' microservice described in Part1.

    Tools can be dynamically upload and register to WorkerAgent during runtime using custom_tools.yaml.

   ![image](https://github.com/xuechendi/docs/assets/4355494/96f3a86a-d6ff-44e5-bb4b-c2d21a9f235c)

  * Expected from End User

    Use exposed 'http API' to interact with entry Agent. query can be in format as plain text, json format text or files.

    > Notice: curl should be sent to entry agent / megaservice gateway
    
    __example__
    ```
    curl ${ip_addr}:${SUPERVISOR_AGENT_PORT}/v1/chat/completions -X POST \
    -d "{'input': 'Generate a Analyst Stock Recommendations by taking an average of all analyst recommendations and classifying them as Strong Buy, Buy, Hold, Underperform or Sell.'}"
    ```
    ![image](https://github.com/xuechendi/docs/assets/4355494/d96b5e26-95a5-4611-9a32-a546eaa324a4)

    
  * Expected from Enterprise User

    Follow pre-defined yaml/python template to compose 'Hierarchical Multi Agent' flow. Use `docker compose` or `helm install` to launch 'Hierarchical Multi Agent' service.
    
    __example__ AGENT Service compose yaml (expected from Enterprise User)

    ``` yaml
    services:
      supervisor_agent:
        ports:
            - ${SUPERVISOR_AGENT_PORT}:${SUPERVISOR_AGENT_PORT}
        image: opea/supervisor-agent:latest
        environment:
          - port=${SUPERVISOR_AGENT_PORT}
          - endpoint=/v1/chat/completions
        env_file: configs/supervisor_agent.env
      llm:
        ports: 
          - ${LLM_SERVICE_PORT}:${LLM_SERVICE_PORT}
        image: opea/llm-tgi:latest
        environment:
          - port=${LLM_SERVICE_PORT}
          - endpoint=/v1/chat/completions
      research_agent:
        ports:
            - ${RESEARCH_AGENT_PORT}:${RESEARCH_AGENT_PORT}
        image: opea/research-agent:latest
        environment:
          - port=${RESEARCH_AGENT_PORT}
          - endpoint=/v1/chat/completions
        env_file: configs/research_agent.env
      writer_agent:
        ports:
            - ${WRITER_AGENT_PORT}:${WRITER_AGENT_PORT}
        image: opea/writer-agent:latest
        environment:
          - port=${WRITER_AGENT_PORT}
          - endpoint=/v1/chat/completions
        env_file: configs/writer_agent.env
     ```

     __example__ supervisor agent Configuration (expected from Enterprise User)
     ``` configs/supervisor_agent.env
     AGENT_NAME=finance AI Assistant
     strategy=reflection
     role=supervisor 
     role_description="The finance AI Assistant is responsible for breakdown a complex finance question into sub tasks and combine output from sub tasks for final answer."
     tools=finance_AI_Assistant_custom_tools.yaml
     require_human_feedback=true
     llm_endpoint_url=http://xx.xx.xx.xx:8080
     llm_engine=tgi
     recursive_limit=5
     ```

     __example__ supervisor agent Tool Configuration (expected from Enterprise User)
     ``` finance_AI_Assistant_custom_tools.yaml
     research_agent:
       description: collect information from type of source, combine in markdown format
       callable_api: http://xx.xx.xx.xx:${RESEARCH_AGENT_PORT}/v1/chat/completions
       args_schema:
         query:
           type: str
           description: Question query to get related financing, stocking, trading, propriety information
       return_output: research_agent_output
     writer_agent:
       description: compose format report using table and diagram based on research_agent_output
       callable_api: http://xx.xx.xx.xx:${WRITER_AGENT_PORT}/v1/chat/completions
       args_schema:
         query:
           type: str
           description: finance report writer
       return_output: report
     ```

     * Possible forms of using 'Hierarchical Multi Agent' yaml to construct
    
       Single Agent Setting
    
       ![image](https://github.com/xuechendi/docs/assets/4355494/49c1214f-4b40-45a6-8760-7c9630ed3d8f)
    
       Multi Level Agent Setting
    
       ![image](https://github.com/xuechendi/docs/assets/4355494/1d791bc6-80c7-4e6c-b27d-220ed1354ee5)


