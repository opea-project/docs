.. _readme_guidelines_genai_examples:

README Guidelines for GenAIExamples
===================================

When you contribute a new sample to GenAI Examples, make sure to prepare a README file for the contribution. The README file explains the sample and describes how other developers can integrate it into their application.

You should be able to deploy your sample through Docker Compose. If your sample also supports other deployment options such as Kubernetes, or can target multiple hardware platforms, you must prepare additional (secondary) README files for those purposes.

Use these guidelines and templates to create primary and secondary README files for your sample.

*Primary README File For a Sample:*
* Structure
* Guidelines
* Template

*Secondary README File(s) For Deployment Options/Target Hardware:* |
* Structure
* Guidelines
* Template


Prepare the Primary README File
###############################

The primary README file for a sample describes an overview of the sample and clarifies its usefulness in solving a practical task.  
Application developers use this information to decide if a sample in GenAI Examples is immediately relevant to their application, so make sure to clarify the value that your sample delivers.

Structure
^^^^^^^^^

Your primary README file should contain these sections:

* *Overview* – Describe the purpose of the sample and the task(s) it can solve.
* *Architecture* – Explain how the sample works. List the building blocks you use from the Generative AI Components (GenAI Comps) folder.
* *Deployment* – Inform how you deploy this sample on all supported hardware platforms.

For an example, open the [primary README file for the ChatQnA application] (https://github.com/opea-project/GenAIExamples/blob/main/ChatQnA/README.md).

Guidelines
^^^^^^^^^^

* The primary README file is the first README file in the sample that application developers use. Keep its content clear and concise so that developers understand the purpose of the sample and know how to learn more about it.
* Do not describe detailed steps in the primary README or insert code blocks for deployment options or targeting specific hardware. Create secondary README files for those purposes and link to them from the primary file.

Template
^^^^^^^^
.. toctree::
   :maxdepth: 1

   Primary README Guidelines for GenAI Examples <primary_readme_genai_examples_template>

----


Prepare the Secondary README File
#################################

The secondary README file explains how you deploy a sample or target it for specific hardware. For deployment, make sure to specify any artifacts that may be necessary. These artifacts can include:
* Compose files or setup scripts to run with Docker Compose
* YAML or HELM charts to deploy with Kubernetes

Structure
^^^^^^^^^

Your secondary README file should contain these sections:

* *Overview* – Describe the contents of the README file. Avoid repeating information that is available in the primary README.
* *Deployment* – Explain how you deploy this sample on a specific hardware platform. Mention prerequisites as well as any optional methods.
* *Validation* - Describe how you check the health of the microservices in this sample.
* *Termination* - Describe how you stop the microservices in this sample.
* *Profiling* - Give information on procedures to set up and monitor profiling dashboards.
* *Troubleshooting* - Describe common problems with this deployment and their solutions.

For an example, open the [Docker Compose file for the ChatQnA application](https://opea-project.github.io/latest/GenAIExamples/ChatQnA/docker_compose/intel/cpu/xeon/README.html#chatqna-docker-compose-files).

Guidelines
^^^^^^^^^^

* Create the secondary README file to help developers set up and run a use case in the fewest steps possible.
* Each target hardware must have only one secondary README file for a specific deployment method.
* To customize a microservice, use the approproate guide available in the GenAI Components folder.
* Only include profiling or debugging information that apply to your specific use case. Include general troubleshooting information in the primary README file.
* Always validate the contents of a secondary README file when you create or update it.

Template
^^^^^^^^
.. toctree::
   :maxdepth: 1

   Secondary README Guidelines for GenAI Examples <secondary_readme_genai_examples_template>
   
----

Validate a Secondary README File
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When you create or update the information in a secondary README file, you must complete a validation process to ensure its quality. 

When you create a new README file, create a new test for validation. When you update a README file, update the corresponding or related test(s) for validation.

All tests are available in the tests folder.
