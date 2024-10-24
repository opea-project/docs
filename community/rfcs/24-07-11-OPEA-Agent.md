# 24-07-11-OPEA-Agent

Agent

## Author

[xuechendi](https://github.com/xuechendi)

## Status

v0.1 team sharing completed(07/10/24)

## Objective

This RFC introduces a new concept of an "Hierarchical Agent," which includes two parts.

*	'Agent’:  Agent refers to a framework that integrates the reasoning capabilities of large language models (LLMs) with the ability to take actionable steps, creating a more sophisticated system that can understand and process information, evaluate situations, take appropriate actions, communicate responses, and track ongoing situations, finally output with result meeting defined goals.

Single Agent Example:

  ![image](https://github.com/xuechendi/docs/assets/4355494/41a40edc-df73-4e3d-8b0a-c206724cc881)

  behind the scene

  ![image](https://github.com/xuechendi/docs/assets/4355494/02232f5b-8034-44f9-a10c-545a13ec5e40)


*	‘Multi Agent' system: Multi Agents refer to a design that leveraging a Hierarchical Agent Teams to complete sub-tasks through individual agent working groups. Benefits of multi-agents’ design: (1) Grouping tools/responsibilities can give better results. An agent is more likely to succeed on a focused task than if it must select from dozens of tools. (2) Each agent will have their own assets including prompt, llm model, planning strategy and toolsets. (3) User can easily use yaml files or few lines of python to build a 'Hierarchical Multi Agent' megaservice by cherry-picking ready-to-use individual agents. (4) For small tasks which can be perfectly performed by single Agent, user can directly use 'Agent' microservice with simple/easy resource management.

Multi Agent example:

```
curl ${ip_addr}:${SUPERVISOR_AGENT_PORT}/v1/chat/completions -X POST \
-d "{'input': 'Generate a Analyst Stock Recommendations by taking an average of all analyst recommendations and classifying them as Strong Buy, Buy, Hold, Underperform or Sell.'}"
```
![image](https://github.com/xuechendi/docs/assets/4355494/d96b5e26-95a5-4611-9a32-a546eaa324a4)

## Motivation

This RFC aims to provide low-code / no-code agents as new microservice / megaservice for Enterprise users who are looking for using their own tools with LLM. Tools includes domain_specific_search, knowledgebase_retrieval, enterprise_servic_api_authorization_required, proprietary_tools, etc.

## Persona

We use the listed terms to define different persona mentioned in this document.

* OPEA developer: OPEA developers describe who will follow current OPEA API SPEC or expand OPEA API SPEC to add new solutions. OPEA developers are expected to use this RFC to understand how this microservice communicates with other microservices and chained in megaflow. OPEA developer develops OPEA agent codes and add new Agent Implementation by extending current Agent library with advanced agent strategies.

* Enterprise User (Devops): Devops describe who will follow OPEA yaml configuration format to update settings according to their real need, or tune some of the configuration to get better performance, who will also use their updated configuration to launch all microservices and get functional endpoint and API calling. Devops are expected to use this RFC to understand the keywords, how these keywords works and rules of using this microservice. Devops are expected to follow customer tool template to provide their own tools and register to Agent microservice.

* End user: End user describe who writes application which will use OPEA exposed endpoints and API to fulfill task goals. End users are expected to use this RFC to understand API keywords and rules.


## Design Proposal

### Execution Plan

 v0.8 (PR ready or merge to opea - agent branch)
  * Agent component v0.1
    * Support chat-completion API
  * Agent example - Insight Assistant v0.1 (IT demo)
    * hierarchical multi agents
    * includes: research(rag, data_crawler); writer(format); reviewer(rule)
  * Agent debug system

V0.9
* Agent component v0.1
  * Support assistants API
  * K8s helm chart
* Agent Example - Insight Assistant v0.1
  * Shared demo with IT
  * Establish IT collaboration effort

V1.0
* Performance benchmark
* Scaling
* Concurrency

### Part 1. API SPEC

  Provide two types of API for different client application.
  1. openAI chat completion API.
  > Reference:  https://platform.openai.com/docs/api-reference/chat/create

  Advantage and limitation:
  * Most common API, should be working with any existing client uses openAI.
  * will not be able to memorize user historical session, human_in_loop agent will not work using this API.

  ```
  "/v1/chat/completions": {
                        "model": str,
                        "messages": list,
                        "tools": list,
                    }
  ```

 2. openAI assistant API
 > Reference:  https://platform.openai.com/docs/api-reference/assistants

 Advantage and limitation:
 * User can create a session thread memorizing previous conversation as long-term memory. And Human-In-Loop agent will only works use this API.
 * User client application may need codes change to work with this new API.
 * openAI assistant API is tagged with ‘beta’, not stable

 ```
 # assistants API is used to create agent runtime instance with a set of tool / append addition instructions
 - "/v1/assistants": {
                         "instructions": str,
                         "name": str,
                         "tools": list
                     }

 # threads API is to used maintain conversation session with one user. It can be resumed from previous, can tracking long term memories.
 - "/v1/threads/ ": { # empty is allowed }


 # threads messages API is to add a task content to thread_1 (the thread created by threads API)
 - "/v1/threads/thread_1/messages": {
                             "role": str,
                             "content": str
                         }

 # threads run API is to start to execute agent thread using run api

 - "/v1/threads/thread_1/runs": {
                             'assistant_id': str,
                             'instructions': str,
                         }
 ```

### Part 2. 'Agent' genAI Component definition

 'Agent' genAI Component is regarded as the resource management unit in “Agent” design.  It will be launched as one microservice and can be instantiated as ‘Agent’, ‘Planner’ or ‘Executor’ according to configuration. Tools will be registered to 'Agent' microservice during launch or runetime.

 ![image](https://github.com/user-attachments/assets/38e83fa4-57d8-4146-9061-e5153472b5f4)

#### SPEC for any agent Role - agent, planner, executor
 ```
 "/v1/chat/completions": {
                         "model": str,
                         "messages": list,
                         "tools": list,
                     }
 "/v1/assistants": {
                         "instructions": str,
                         "name": str,
                         "tools": list
                     }
 "/v1/threads/: {}
 "/v1/threads/thread_1/runs": {
                             'assistant_id': str,
                             'instructions': str,
                         }
 "/v1/threads/thread_1/messages": {
                             "role": str,
                             "content": str
                         }
 ```

#### Agent Role microservice definition - 'Agent':
  A complete implementation of Agent, which contains LLM endpoint as planner, strategy algorithm for plan execution, Tools, and database handler to keep track of historical state and conversation.

  configuration:
  ```
  strategy: choices([react, planexec, humanInLoopPlanExec])
  require_human_feedback: bool
  llm_endpoint_url: str
  llm_engine: choices([tgi, vllm, openai])
  llm_model_id: str
  recursion_limit: int
  tools: file_path or dict

  # Tools definition
  [tool_name]:
    description: str
    callable_api: choices([http://xxxx, xxx.py:func_name])
    env: str
    pip_dependencies: str # sep by ,
    args_schema:
      query:
        type: choices([int, str, bool])
        description: str
    return_output: str
  ```

#### Agent Role microservice definition - 'Planner':
  Agent without tools. Planner only contains LLM endpoints as planner, certain strategies to complete an optimized plan.

  configuration:
  ```
  strategy: choices([react, planexec, humanInLoopPlanExec])
  require_human_feedback: bool
  llm_endpoint_url: str
  llm_engine: choices([tgi, vllm, openai])
  llm_model_id: str
  recursion_limit: int
  require_human_feedback: bool
  ```

#### Agent Role microservice definition - 'Executor':
  Tools executors. Executor is used to process input with registered tools.

  Configuration:
  ```
  [tool_name]:
  description: str
  callable_api: choices([http://xxxx, xxx.py:func_name])
  env: str
  pip_dependencies: str # sep by ,
  args_schema:
    query:
      type: choices([int, str, bool])
      description: str
  return_output: str
  ```

  > Any microservcice follow this spec can be registered as role in Part3-graph-based

### Part3. 'Multi Agent' system overview

We planned to provide multi-agent system in two phases.

* Phase I: Hierarchical Multi Agents
  1.	In this design, only top-layer Agent will be exposed to OPEA mega flow. And only ‘Agent’ microservice will be used to compose Hierarchical Multi Agents system.
  2.	Users are only allowed to use yaml files to provide tools configuration, high-level instructions text and hierarchical relationship between agents.
  3.	This design simplifies the agent configuration, using simple yaml definition can still be used to compose a multi agent system to handle complex tasks.
  > Detailed configuration please refer to Part3.1
  ![image](https://github.com/user-attachments/assets/be3bef3a-a1c9-4059-a8a1-e8e52e0d6c16)


* Phase II: Graph-Based Multi Agent
  1.	In this design, we provide user a new SDK to compose a graph-based multi agents system with conditional edge to define all strategic rules.
  2.	Enterprise user will be able to use python code to wrap either ‘agent’, ‘planner’ or tools  as ‘Role’ and add conditional edges between them for complex task agent design.
  3.	This design provides user enough flexibility to handle very complex tasks and also provide flexibility to handle resource management when certain tools are running way slower than others.
  > Detailed configuration please refer to Part3.2
  ![image](https://github.com/user-attachments/assets/35b36f64-eaa1-4f05-b25e-b8bea013680d)

#### Part3.1 Hierarchical Multi Agents

__Example 1__: ‘Single Agent megaservice’
Only 1 agent is presented in this configuration.
![image](https://github.com/user-attachments/assets/2e716dd4-2923-4ebd-97bf-fe7a44161280)

3 tools are registered to this agent through custom_tools.yaml
![image](https://github.com/user-attachments/assets/5b523ff2-9193-4b0c-b606-4149fd3e8612)

![image](https://github.com/user-attachments/assets/5ad3c2a9-dc50-472b-8352-041ae4b6a9c6)
![image](https://github.com/user-attachments/assets/ec89e35b-8ccc-474b-9fb7-3ed7210acc10)

__Example 2__: ‘Hierarchical Multi Agents’
3 agents are presented in this configuration, 1st layer supervisor agent is the gateway to interact with user, and 1st layer agent will manage 2nd layer worker agents.

![image](https://github.com/user-attachments/assets/a83b51e6-ee08-473f-b389-51df48f1054f)

Users are expected to register 2nd layer workerAgents to 1st layer supervisor agent through supervisor_agent_custom_tools.yaml file.
![image](https://github.com/user-attachments/assets/d07223e9-4290-4ea7-8416-0caa2540bce1)

![image](https://github.com/user-attachments/assets/9cc3825f-c77f-4482-bf10-292c08235f3b)
![image](https://github.com/user-attachments/assets/62bc9644-5308-4d4b-9784-a022dc26c37a)

> User can follow this way to add more layers:
![image](https://github.com/user-attachments/assets/cc42fe97-4adf-44c9-a95a-c4bef8e26000)

__Example 3__: ‘Multi Steps Agent megaservice’:

User can also chain agent into a multi-step mega service. audioAgent_megaservice.yaml
![image](https://github.com/user-attachments/assets/5fb18d75-9c08-4d7b-97f7-25d7227147dd)

#### Part3.2 Graph-Based Multi Agent
In Phase II, we propose to provide a graph-based multi agents system, which enterprise user will be able to define edges and conditional edges between agent nodes, planner nodes and tools for complex task agent design.

![image](https://github.com/user-attachments/assets/7c07e651-43ed-4056-b20a-cd39f3f883ee)

The user can build and launch the graph-based message group by the combination of docker image and yaml file:
![image](https://github.com/user-attachments/assets/5c84f728-ff87-45c9-8f09-ecd5428da454)

The yaml file contains the basic config information for each single “Role” in the agent architecture. The user can build a MessageGroup to define the link connection information and the data flow via “edges” and “conditional_edges”. The “edges” mean the output of the head_node is the input of the tail_node. The “conditional_edges” means there is a decision-making among the candidate tail_nodes based on the output of the head_node. The logic of this selection part is defined by the state component “Should_Continue”.
![image](https://github.com/user-attachments/assets/55ecb718-b134-4546-9496-40ac3a427a7b)

Appending agents/roles in MessageGroup.
Define the role class define the action of the role  add edges  recompile the messagegroup
![image](https://github.com/user-attachments/assets/65a3fc1d-89f3-4bb3-a078-75db91400c58)

#### Part 4. Agent Debug System

TBD

#### Part 5. Benchmark

TBD

