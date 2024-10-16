# 24-08-05 OPEA Workflow Executor Example

## Author

[OngSoonEe](https://github.com/OngSoonEe)
[JoshuaL3000](https://github.com/JoshuaL3000)

## Status

Under Review

## RFC Content

### Objective

This RFC aims to add a new GenAIExample -- GenAI Workflow Execution Example, to showcase capability to handle data/AI workflow operations via LLM agent. This example demonstrates how user can easily interface with complex external workflows through high-level API's by prompting the agent to execute custom-defined workflow based tools.

### Motivation

There exist tools in the market (no-code/low-code/IDE), e.g. Alteryx, RapidMiner, Power BI, Intel Data Insight Automation, that allows users to create complex data/AI workflow operation for different use-cases. For example, marketing data insight extraction, product segmentation (DL), puchase behavior prediction (DL), complex data transformation, and so on. However, connecting these workflow operations to LLM are not trivial today. It requires extensive engineering work and the know-how to chain the operation in a LLM application.

Ability to provide a simple method that allow OPEA users to extend GenAI capability to such workflows via agent function calls will greatly reduce time for GTM. This RFC will extend an agent strategy GenAIComps called `Workflow Executor` under agent/langchain. The strategy will be using a multiagent supervisor router build on top of Langgraph.

### Design Proposal (draft for initial phase)

#### Workflow Executor

Workflow Executor is a multiagent microservice dedicated for running workflow operation tools. Comprising of a supervisor agent and mainly of 3 tools, the user can execute workflows to retrieve output data and reasoning with a request.

The supervisor handles the routing to the next worker agent. In this simple design, the supervisor should start with workflow scheduler, then choose workflow status checker, followed by workflow data retriever, which the last worker agent will provide the reasoning and final answer back to the user.

The tools used in workflow executor strategy are listed below:

1. Workflow Scheduler
    - Starts the workflow with workflow parameters extracted from the user query

2. Workflow Status Checker
    - Periodically checks the workflow status for completion or failure. This may be through a database which stores the current status of the workflow

3. Workflow Data Retriever
    - Retrieves the output data from the workflow through a storage service
    - From the data output, the agent will answer the input prompt from the user as the `Final Answer`

An illustration of the above structure and flow is shown in the image below

![image](https://github.com/user-attachments/assets/4b8691f7-1f30-4dd8-8f68-15108e90f6b2)

Here's what the `Workflow Executor` diagram looks like:

![image](https://github.com/user-attachments/assets/a4c5d183-115b-4a36-b903-577de91a6a8d)

#### Workflow Serving for Agent

In this example, a Churn Prediction use-case workflow is used as the serving workflow for the agent execution. It is created through Intel Data Insight Automation platform. The image below shows a snapshot of the Churn Prediction workflow.

![image](https://github.com/user-attachments/assets/c067f8b3-86cf-4abc-a8bd-51a98de8172d)

The workflow contains 2 paths which can be seen in the workflow illustrated, the top path and bottom path. The top path which ends at the random forest classifier node is the training path. The data is cleaned through a series of nodes and used to train a random forest model for prediction. The bottom path is the inference path where trained random forest model is used for inferecing based on input parameter.

For this agent workflow execution, the inferencing path is executed to yield the final output result of the `Model Predictor` node. The same output is returned to the `Workflow Data Retriever` tool through the `Langchain API Serving` node.

There are `Serving Parameters` in the workflow, which are the variables the agent updates based on the `params` extracted from the user query. 

![image](https://github.com/user-attachments/assets/ce8ef01a-56ff-4278-b84d-b6e4592b28c6)

Manually running the workflow yields the tabular data output as shown below:

![image](https://github.com/user-attachments/assets/241c1aba-2a24-48da-8005-ec7bfe657179)

In the workflow serving, this output will be returned through the `Workflow Data Retriever` tool. The LLM can then answer the user's original question based on this output.

An example of the agent microservice in action is shown below, where the user prompts the agent with workflow parameters included in the query.

```sh
$ curl http://${ip_address}:${port}/start -X POST -H "Content-Type: application/json" -d '{
    "query": "I have a data with gender Female, tenure 55, MonthlyAvgCharges 103.7. Predict if this entry will churn. My workflow is 8925."
    }'

data: "Based on the data retrieved from the workflow, the entry with gender Female, tenure 55, and MonthlyAvgCharges 103.7 is predicted to churn"

data: [DONE]
```

The user has to provide a `workflow_id` and workflow `params` in the query. `workflow_id` a unique id used for serving the workflow to the microservice. Notice that the `query` string includes all the workflow `params` which the user defined in the workflow. The agent will extract these parameters into a dictionary format for the workflow `Serving Parameters` as shown below:

```python
params = {
    "gender": "Female", 
    "tenure": 55, 
    "MonthlyAvgCharges": 103.7
}
```

These parameters will be passed into the workflow executor tool to start the workflow execution of specified `workflow_id`. Thus, everything will be handled via the microservice.

The image below shows the background process of the agent in action when the workflow executor agent is run. 

![image](https://github.com/user-attachments/assets/6d44b811-b8de-460e-bea7-b6fb727f1104)

Once the LLM answers the user's query after obtaining the output data, the `supervisor` exits the chain with 'FINISH'.

The list below briefly shows the descriptions of the tools used in this example design.

```yaml
workflow_scheduler:
    description: Executes a workflow
    pip_dependencies: 
    callable_api: https://SDK_BASE_URL/serving/servable_workflows/{workflow_id}/start
    args_schema:
        workflow_id: int
        params:
            type: dict
            description: User input prompt to provide workflow parameters and workflow id
    return_output: workflow status

workflow_status_checker:
    description: Retrieves status of a running workflow
    pip_dependencies: 
    callable_api: https://SDK_BASE_URL/serving/servable_workflows/{workflow_id}/status
    args_schema:
        workflow_id: int
    return_output: workflow status

workflow_data_retriever:
    description: Retrieves final data output from workflow
    pip_dependencies: 
    callable_api: https://SDK_BASE_URL/serving/servable_workflows/{workflow_id}/results
    args_schema:
        workflow_id: int
    return_output: workflow output data
```

### Compatibility

### Miscs
