# 24-08-07 OPEA-001 OPEA GenAIStudio

## Author

[ongsoonee](https://github.com/OngSoonEe)
[chinyixiang](https://github.com/chinyixiang)

## Status

Under Review

## RFC Content

### Objective

The purpose of this RFC is to propose the creation of GenAI Studio, a platform designed to facilitate the development of custom large language model (LLM) applications, leveraging insights from the playground experimentation phase. GenAI Studio will enable users to construct, evaluate, and benchmark their LLM applications through a user-friendly no-code/low-code interface. The platform also provide the capability to export the developed application as a ready-to-deploy package for immediate enterprise integration. This initiative aims to streamline the transition from concept to production, ensuring a seamless deployment process for day-0 enterprise applications.

### Motivation

This RFC outlines the creation of the Enterprise GenAI Assembly Framework, a streamlined platform for OPEA users. The framework's key goals include:
- Assembly and Configuration: Simplify the process of assembling and configuring GenAI components, such as GenAIComps, with an interactive interface for crafting functional applications.
- Benchmarking and Evaluation: Perform benchmarking and evaluation on the application for tuning and optimization, including use of [GenAIEval](https://github.com/opea-project/GenAIEval) facilities.
- Enterprise Deployment Package Creation: Provide tools to create ready-to-deploy Enterprise Packages, including integration of [GenAIInfra](https://github.com/opea-project/GenAIInfra).

The framework is designed to democratize development, evaluation, and deployment of GenAI applications for OPEA users, promoting innovation and operational efficiency in the enterprise AI landscape with OPEA.

### Value Proposition
#### Current Approach
![Current Approach of GenAI Solution for enterprise](https://github.com/user-attachments/assets/adb10f29-b506-46d6-abd3-ed5f70049bee)

Days/weeks before 1st working solution

#### GenAI Studio Approach
![Proposed GenAIStudio Approach](https://github.com/user-attachments/assets/e0c59dd2-0ff5-4deb-9561-8cba4ab5defe)

A Day-0 solution that offers users a foundational skeleton, allowing them to focus on business use-cases rather than building the basic framework.

### Persona
OPEA is a framework designed to streamline the automation of enterprise processes through a series of microservices. The GenAI Studio enhances OPEA by enabling users to develop, deploy, and optimize AI-driven solutions. This scenario demonstrates how different personas—OPEA Developers, Enterprise Users (DevOps), and End Users—can leverage the GenAI Studio to build and deploy enterprise-ready solutions efficiently.

Scenarios:

1. Developer Persona
   - Objective: Develop and integrate GenAI Application for specific business use-case within OPEA microservice architecture.
   - Use of the Studio:
     - The OPEA Developer uses the GenAI Studio to create a GenAI model help enhances business use-case
     - The Studio's advanced development tools allow the developer to fine-tune the model based on enterprise-specific data, ensuring optimal performance.
     - After development, the Studio automatically generates a ready-to-use enterprise deployment package that includes all necessary components, such as configurations and resource management tools, ensuring seamless integration with the existing OPEA infrastructure.
     - This package is designed to be easily deployable at the customer’s site, minimizing the need for additional configuration and setup.

2. Enterprise User Persona
   - Objective: Optimize and deploy the GenAI application with OPEA microservices to meet specific enterprise needs.
   - Use of the Studio:
     - The enterprise user uses the GenAI Studio to test and optimize the deployment package generated.
     - With the Studio’s benchmarking tools, they evaluate the AI model's performance from both inference and compute perspectives, ensuring it meets the enterprise's operational requirements.
     - The Studio provides insights into resource allocation, helping DevOps fine-tune the deployment to achieve the best possible performance. Once optimized, the deployment package is easily launched, allowing the enterprise to immediately benefit from the AI enhancements.

3. End User Persona
   - Objective: Implement and utilize the AI-enhanced OPEA solution for specific business tasks.
   - Use of the Studio:
     - The End User accesses the GenAI Studio to explore the ready-to-use deployment package provided by the DevOps team.
     - The Studio offers tools to evaluate the solution's performance in real-world scenarios, ensuring it aligns with the business’s objectives.
     - With minimal setup, the End User can deploy the AI-enhanced solution in their environment, automating complex workflows and optimizing resource usage to achieve business goals more efficiently.

The Generative AI Studio empowers Developers, Enterprise User, and End Users to create, optimize, and deploy AI-driven enterprise solutions effortlessly. By providing tools to generate ready-to-use deployment packages and benchmark performance, the Studio ensures that AI solutions are not only powerful but also easy to deploy and maintain, making them highly effective for business applications.

### Stragegy and Scope of Work

Not reinventing the wheel - leverage existing work from OPEA, open-source and EasyData foundation works.
- GMC on configuration/deploy
- Langflow/flowise.ai for app configuration
- Suites of performance evaluation (VictoriaMetric, OpenTelemetry (Otel), Tempo, Loki, Grafana)
- Istio for workload management

Scope of model development/optimization

| Scope of Work | Status |
| --- | --- |
| Prompt engineering, RAG | In scope |
| Model Finetune | Stretch Goal |
| Model Pre-train | Out of Scope |

### GenAI Studio High Level Architecture
![OPEA GenAI Studio Architecture](https://github.com/user-attachments/assets/fa55aeae-158b-4035-8325-25821c24a27f)

### Design Proposal

### Design Space
Providing a interactive user interface for user to build, configure, test and generate final deployment package.
User may utilize the yaml data file for creation and modification of studio project, as an alternate to GUI.

#### Part 1: Application Build and Configuration
User to build GenAI application with configuration, such as
- model selection
- model parameter setting (temp, top-p, top-k, max response)
- system instruction

Provides 2 mode of configuration
- Wizard Mode: User is guided through step-by-step process to create an application
    - ![screenshot sample of wizard mode](https://github.com/user-attachments/assets/1c780be1-d6dc-47fb-8a23-5229392ab45b)
- Drag-n-drop Workflow Mode: Allow user to create their own flow from available components (leverage Flowise AI)
    - Utilize Flowise AI - https://docs.flowiseai.com/
    - Note: Need further feasibility study on
        - Ease of customization or adding new UI components
        - Connectivity and integration to Mega Service (HelmChart, DockerCompose, GMC)



#### Part 2: Benchmark and Evaluation
A. Inference Performance
- General Benchmarking
    - GLUE/SuperGLUE
    - GPQA
    - SQuAD
    - ImageNet
    - MLPerf
- Halucination
- Vertical/Domain Specific Benchmarking (with ground truth)
- Finetuning – next phase

B. Model Compute Performance
- token-per-sec (TPS)
- 1st token latency
- Throughput
- RAG performance

C. Resource Monitoring - CPU utilization, memory utilization
![Diagram on resource monitoring architecture](https://github.com/user-attachments/assets/0fe9fed7-0979-4325-b242-fcd753b19f09)

Enablement of components for compute performance evaluation
- VictoriaMetric: as metrics store for resource utilization
- OpenTelemetry (Otel): tracing probing mechanism
- Tempo: Trace store for OpenTelemetry
- Loki: log store for pod/Kubernetes
- Grafana: visualization of metrics, trace and logs
- Prometheus

#### Part 3: Enterprise Deployment
Generate Enterprise Deployment Package base on the applicaiton with enterprise facilities features, including,
Features:
- Application UI
- user management (login, create, update, delete)
- Session management (e.g. Chat sessions)
- inference parameter setting (top-p, top-k, temperature)
- Vector Store
- token generation
- API access

Applications:
- QnA
- AudioChat
- VisualChat
- Translation
- CodeGen
- CodeTrans
- Summarizer

Deployment configuration - Sample UI
- OS
- Cloud/ OnPrem
- Cluster /single Machine
- Feature selection (API access, user management etc)
- Monitoring dashboard for Resource Management

![GenAI Deployment Package Configuration](https://github.com/user-attachments/assets/8dd43bff-26a6-4c3e-a80c-127bccdff7f3)

Generated Deployment Package generally contains the follow parts:
- Ansible playbooks - Ansible playbooks will be used to setup and initialize important services such as K8s, SQL Database, local image registry, etc.
- App UI codes
- App backend server codes
- Other OPEA microservice component images can be pulled from OPEA registry directly during setup.


### Compatibility
This RFC will require a feasibility study on tools to use for Part 1 Drag-n-Drop Workflow Mode design. Flowise AI is a good candidate but it needs to run as a separate service which will add to the complexity of the UI/UX design.
