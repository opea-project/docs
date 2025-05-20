# Template for Secondary README File

**Deploy <sample name> Application on <hardware>**

## Contents
- Overview
- Deployment
- Additional Options for Deployment
- Validation
- Profiling
- Termination
- Troubleshooting


## Overview
<What is the purpose of this README file?> 

## Deployment
<What are the prerequisites before you deploy the sample on the target hardware?> 
<What environment variables should be set before running Docker Compose?>

| Environment Variable                | Description                            | Default Value               |
| ------------------------------------| ---------------------------------------------------------------------|
|                                     |                                        |                             |
|                                     |                                        |                             |

<How do you check the status of the deployment?>   


*Additional Options for Deployment*
<Use this table to describe additional options that are available for this deployment, such as vector databases or LLM serving engine. List the YAML files to use for these options.>

| File                                | Description                                                          |
| ------------------------------------| ---------------------------------------------------------------------|
|                                     |                                                                      |                                                                                                                                                                                                                                 

## Validation
<How do you validate the health of the microservices that are used in this sample?>

<For each microservice, your validation should display:>
- <The name of the microservice>
- <The test procedure used>
- <Applicable CURL commands>
- <An example of the expected output>

<Also include instructions to open the UI:>
- <What port should the developer use?>
- <Is port forwarding necessary?>
- <For Intel® Tiber™ AI Cloud (ITAC), is a load balancer necessary?>
- <Do specific instructions apply for different UIs?>
- <What should the sample input and output look like? Include screenshots.>


## Profiling
<If supported, how do you profile the microservices that are used in this sample?>
<How do you prepare dashboards in Prometheus or Grafana for this purpose?>

## Termination
<How do you stop the microservices?>

## Troubleshooting
<Describe common problems encountered when deploying this specific use case. Include general troubleshooting information in the primary README.>

## Related Information
<Include links to:>
- <Relevant GenAI Examples>
- <Relevant microservices in GenAI Components>
- <Relevant OPEA tutorials>