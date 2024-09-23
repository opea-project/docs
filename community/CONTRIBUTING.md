# Contribution Guidelines

Thanks for considering contributing to OPEA project. The contribution process is similar with other open source projects on Github, involving an amount of open discussion in issues and feature requests between the maintainers, contributors and users.


## All The Ways To Contribute

### Contribute a GenAI Component

1. Navigate to [OPEA GenAIComps](https://github.com/opea-project/GenAIComps) and locate the component folder your integration belongs to. If the microservice type already exists, review the [OPEA microservice API](https://opea-project.github.io/latest/developer-guides/OPEA_API.html#opea-micro-service-api) and follow it in your implementation. Otherwise, if you are contributing a brand new microservice type, you need to define and contribute first its API specification. Please start by submitting an RFC to get community feedback.


    ```
    GenAIComps
    ├── comps
    │   ├── agent
    │   ├── asr
    │   ├── chathistory
    │   ├── cores
    │   │   ├── mega     #orchestrator, gateway, micro_service class code
    │   │   ├── proto    #api protocol
    │   │   └── telemetry
    │   ├── dataprep
    │   ├── embeddings
    │   ├── feedback_management
    │   ├── finetuning
    │   ├── guardrails
    │   ├── intent_detection
    │   ├── knowledgegraphs
    │   ├── llms
    │   ├── lvms
    │   ├── nginx
    │   ├── prompt_registry
    │   ├── ragas
    │   ├── reranks
    │   ├── retrievers
    │   ├── tts
    │   ├── vectorstores
    │   └── web_retrievers
    └── tests
        ├── agent
        ├── asr
        ├── chathistory
        ├── cores
        ├── dataprep
        ├── embeddings
        ├── feedback_management
        ├── finetuning
        ├── guardrails
        ├── intent_detection
        ├── llms
        ├── lvms
        ├── nginx
        ├── prompt_registry
        ├── reranks
        ├── retrievers
        ├── tts
        ├── vectorstores
        └── web_retrievers
    ```

2. Follow the folder structure in the TEI embedding component below:

    ```
    GenAIComps
    ├── comps
    │   └── embeddings
    │       ├── __init__.py
    │       └── tei     #vendor name or serving framework name
    │           ├── langchain
    │           │   ├── Dockerfile
    │           │   ├── Dockerfile.amd_gpu
    │           │   ├── Dockerfile.nvidia_gpu
    │           │   ├── embedding_tei.py    # definition and registration of microservice
    │           │   ├── README.md
    │           │   └── requirements.txt
    │           └── llama_index
    │               └── . . .
    ├── tests
    │   └── embeddings
    │       ├── test_embeddings_tei_langchain.sh
    │       ├── test_embeddings_tei_langchain_on_amd_gpu.sh
    │       └── test_embeddings_tei_llama_index.sh
    └── README.md

    ```

    - **File Descriptions**:
      - `embedding_tei.py`: This file defines and registers the microservice. It serves as the entrypoint of the Docker container. Refer to [whisper ASR](https://github.com/opea-project/GenAIComps/tree/main/comps/asr/whisper/README.md) for a simple example or [TGI](https://github.com/opea-project/GenAIComps/blob/main/comps/llms/text-generation/tgi/llm.py) for a more complex example that required adapting to the OpenAI API.
      - `requirements.txt`: This file is used by Docker to install the necessary dependencies.
      - `Dockerfile`: Used to generate the service container image. Please follow naming conventions:
        - Dockerfile: `Dockerfile.[vendor]_[hardware]`, vendor and hardware in lower case (i,e Dockerfile.amd_gpu)
        - Docker Image: `opea/[microservice type]-[microservice sub type]-[library name]-[vendor]-[hardware]:latest` all lower case (i,e opea/llm-vllm-intel-hpu, opea/llm-faqgen-tgi-intel-hpu-svc)

      - `tests/[microservices type]/` : contains end-to-end test for microservices Please refer to an example [test_asr_whisper.sh](https://github.com/opea-project/GenAIComps/blob/main/tests/asr/test_asr_whisper.sh). Please follow naming convention:`test_[microservice type]_[microservice sub type]_[library name]_on_[vendor]_[hardware].sh`
      - `tests/cores/` : contains Unit Tests (UT) for the core python components (orchestrator, gateway...). Please follow the naming convention:`test_[core component].sh`

      - `README.md`: at minimum it should include: microservice description, build, and start commands and a curl command with expected output.

4. Now you have created all the required files, and validated your service. Last step is to modify the `README.md` at the component level `GenAIComps/comps/[microservice type]` to list your new component. Now you are ready to file your PR! Once your PR is merged, in the next release the project  release maintainers will publish the Docker Image for the same to the Docker Hub.

5. After your component has been merged, you are likely interested in building an application with it, and perhaps contributing it also to OPEA! Please continue on to the [Contribute a GenAI Example](#contribute-a-genai-example) guide.

### Contribute a GenAI Example

Each of the samples in OPEA GenAIExamples are a common oft used solution. They each have scripts to ease deployment, and have been tested for performance and scalability with Docker compose and Kubernetes. When contributing an example, a Docker Compose deployment is the minimum requirement. However, since OPEA is intended for enterprise applications, supporting Kubernetes deployment is highly encouraged. You can find [examples for Kubernetes deployment](https://github.com/opea-project/GenAIExamples/tree/main/README.md#deploy-examples) using manifests, Helms Charts, and the [GenAI Microservices Connector (GMC)](https://github.com/opea-project/GenAIInfra/tree/main/microservices-connector/README.md). GMC offers additional enterprise features, such as the ability to dynamically adjust pipelines on Kubernetes (e.g., switching to a different LLM on the fly, adding guardrails), composing pipeleines that include external services hosted in public cloud or on-premisees via URL, and supporting sequential, parallel and conditional flows in the pipelines.

- Navigate to [OPEA GenAIExamples](https://github.com/opea-project/GenAIExamples/tree/main/README.md) and check the catalog of examples. If you find one that is very similar to what you are looking for, you can contribute your variation of it to that particular example folder. If you are bringing a completly new application you will need to create a separate example folder.

- Before stitching together all the microservices to build your application, let's make sure all the required building blocks are available!. Take a look at this **ChatQnA Flow Chart**:

```mermaid
---
config:
  flowchart:
    nodeSpacing: 100
    rankSpacing: 100
    curve: linear
  theme: base
  themeVariables:
    fontSize: 42px
---
flowchart LR
    %% Colors %%
    classDef blue fill:#ADD8E6,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
    classDef orange fill:#FBAA60,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
    classDef orchid fill:#C26DBC,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
    classDef invisible fill:transparent,stroke:transparent;
    style ChatQnA-MegaService stroke:#000000
    %% Subgraphs %%
    subgraph ChatQnA-MegaService["ChatQnA-MegaService"]
        direction LR
        EM([Embedding <br>]):::blue
        RET([Retrieval <br>]):::blue
        RER([Rerank <br>]):::blue
        LLM([LLM <br>]):::blue
    end
    subgraph User Interface
        direction TB
        a([User Input Query]):::orchid
        Ingest([Ingest data]):::orchid
        UI([UI server<br>]):::orchid
    end
    subgraph ChatQnA GateWay
        direction LR
        invisible1[ ]:::invisible
        GW([ChatQnA GateWay<br>]):::orange
    end
    subgraph .
        X([OPEA Micsrservice]):::blue
        Y{{Open Source Service}}
        Z([OPEA Gateway]):::orange
        Z1([UI]):::orchid
    end

    TEI_RER{{Reranking service<br>}}
    TEI_EM{{Embedding service <br>}}
    VDB{{Vector DB<br><br>}}
    R_RET{{Retriever service <br>}}
    DP([Data Preparation<br>]):::blue
    LLM_gen{{LLM Service <br>}}

    %% Data Preparation flow
    %% Ingest data flow
    direction LR
    Ingest[Ingest data] -->|a| UI
    UI -->|b| DP
    DP <-.->|c| TEI_EM

    %% Questions interaction
    direction LR
    a[User Input Query] -->|1| UI
    UI -->|2| GW
    GW <==>|3| ChatQnA-MegaService
    EM ==>|4| RET
    RET ==>|5| RER
    RER ==>|6| LLM


    %% Embedding service flow
    direction TB
    EM <-.->|3'| TEI_EM
    RET <-.->|4'| R_RET
    RER <-.->|5'| TEI_RER
    LLM <-.->|6'| LLM_gen

    direction TB
    %% Vector DB interaction
    R_RET <-.->|d|VDB
    DP <-.->|d|VDB

```

- OPEA uses gateways to handle requests and route them to the corresponding megaservices (unless you have an agent that will otherwise handle the gateway function). If you are just making small changes to the application, like swaping one DB for another, you can reuse the existing Gateway but if you are contributing a completely new application, you will need to add a Gateway class. Navigate to [OPEA GenAIComps Gateway](https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/gateway.py) and implement how Gateway should handle requests for your application. Note that Gateway implementation is moving to GenAIExamples in future release.

- Follow the folder structure in the ChatQA example below:

    ```
    ├── assets
    ├── benchmark     # optional
    ├── chatqna.py    # Main application definition (microservices, megaservice, gateway).
    ├── chatqna.yaml  # starting v1.0 used to generate manifests for k8s w orchestrator_with_yaml
    ├── docker_compose
    │   ├── intel
    │   │   ├── cpu
    │   │   │   └── xeon
    │   │   │       ├── compose.yaml
    │   │   │       ├── README.md
    │   │   │       └── set_env.sh  #export env variables
    │   │   └── hpu
    │   │       └── gaudi
    │   │           ├── compose.yaml
    │   │           ├── how_to_validate_service.md    #optional
    │   │           ├── README.md
    │   │           └── set_env.sh
    │   └── nvidia
    │       └── gpu
    │           ├── compose.yaml
    │           ├── README.md
    │           └── set_env.sh
    ├── Dockerfile
    ├── docker_image_build
    │   └── build.yaml
    ├── kubernetes
    │   ├── intel
    │   │   ├── cpu
    │   │   │   └── xeon
    │   │   │       ├── gmc
    │   │   │       │   └── chatQnA_xeon.yaml
    │   │   │       └── manifest
    │   │   │           └── chatqna.yaml
    │   │   └── hpu
    │   │       └── gaudi
    │   │           ├── gmc
    │   │           │   └── chatQnA_gaudi.yaml
    │   │           └── manifest
    │   │               └── chatqna.yaml
    │   ├── amd
    │   │   ├── cpu
    │   │   │   ├── gmc
    │   │   │   └── manifest
    │   │   └── gpu
    │   │       ├── gmc
    │   │       └── manifest
    │   ├── README_gmc.md  # K8s quickstar
    │   └── README.md      # quickstart
    ├── README.md
    ├── tests
    │   ├── test_compose_on_gaudi.sh  #could be more tests for different flavors of the app
    │   ├── test_gmc_on_gaudi.sh
    │   ├── test_manifest_on_gaudi.sh
    └── ui

    ```

    - **File Descriptions**:
      - `chatqna.py`: application definition using microservice, megaservice and gateway. There could be multiple .py in the folder based on slight modification of the example application.
      - `docker_build_image/build.yaml`: builds necessary images pointing to the Dockerfiles in the GenAIComp repository.
      - `docker_compose/vendor/device/compose.yaml`: defines pipeline for  Docker compose deployment. For selectng docker image name please follow the naming convention:
        - Docker Image: `opea/[example name]-[feature name]:latest` all lower case (i,e: opea/chatqna, opea/codegen-react-ui)
      - `kubernetes/vendor/device/manifests/chatqna.yaml`: used for K8s deployemnt
      - `kubernetes/vendor/device/gmc/chatqna.yaml`: (optional) used for deployment with GMC
      - `tests/`: at minimum you need to provide an E2E test with Docker compose. If you are contritbutng K8s manifests and GMC yaml, you should also provide test for those. Please follow naming convention:
        - Docker compose test: `tests/test_compose_on_[hardware].sh`
        - K8s test: `tests/test_manifest_on_[hardware].sh`
        - K8s with GMC test: `tests/test_gmc_on_[hardware].sh`
      - `ui`: (optional)
      - `assets`: nice to have an application flow diagram

#### Additional steps if your contribution is Hardware Specific

You will need additional steps to configure the CI/CD for first testing and then deploying your merged  GenAIComp or GenAIExample.

- Connect hardware into OPEA GitHub Actions ([GHA](https://docs.github.com/en/actions)) as a self-hosted runner
- Contribute test scripts for the new hardware
- Dockerfile for the Component (i,e `GenAIComp/comps/llm/text-generation/tgi/Dockerfile.[vendor]_[hardware]` )
- Update the image build yaml for new images
- Update the CI/CD workflow to identify and deploy new test

OPEA maintainer [@chensuyue](mailto://suyue.chen@intel.com) can assist in this process.

### Community Discussions

Developers are encouraged to participate in discussions by opening an issue in one of the GitHub repos at https://github.com/opea-project. Alternatively, they can send an email to [info@opea.dev](mailto://info@opea.dev) or subscribe to [X/Twitter](https://twitter.com/opeadev) and [LinkedIn Page](https://www.linkedin.com/company/opeadev/posts/?feedView=all) to get latest updates about the OPEA project.

### Documentation

The quality of OPEA project's documentation can have a huge impact on its success. We reply on OPEA maintainers and contributors to build clear, detailed and update-to-date documentation for user.

### Reporting Issues

If OPEA user runs into some unexpected behavior, reporting the issue to the `Issues` page under the corresponding github project is the proper way to do. Please ensure there is no similar one already existing on the issue list). Please follow the Bug Report template and supply as much information as you can, and any additional insights you might have. It's helpful if the issue submitter can narrow down the problematic behavior to a minimal reproducible test case.

### Proposing New Features

OPEA communities use the RFC (request for comments) process for collaborating on substantial changes to OPEA projects. The RFC process allows the contributors to collaborate during the design process, providing clarity and validation before jumping to implementation.

*When the RFC process is needed?*

The RFC process is necessary for changes which have a substantial impact on end users, workflow, or user facing API. It generally includes:

- Changes to core workflow.
- Changes with significant architectural implications.
- changes which modify or introduce user facing interfaces.

It is not necessary for changes like:

- Bug fixes and optimizations with no semantic change.
- Small features which doesn't involve workflow or interface change, and only impact a narrow use case.

#### Step-by-Step guidelines

- Follow this RFC Template to propose your idea (found in the docs repo community/rfcs/rfc_template.txt):

  ```{literalinclude} rfcs/rfc_template.txt
  ```

- Submit the proposal to the `Issues` page of the corresponding OPEA github repository.
- Reach out to your RFC's assignee if you need any help with the RFC process.
- Amend your proposal in response to reviewer's feedback.

### Submitting Pull Requests

#### Create Pull Request

If you have improvements to OPEA projects, send your pull requests to each project for review.
If you are new to GitHub, view the pull request [How To](https://help.github.com/articles/using-pull-requests/).

##### Step-by-Step guidelines

- Star this repository using the button `Star` in the top right corner.
- Fork the corresponding OPEA repository using the button `Fork` in the top right corner.
- Clone your forked repository to your pc by running `git clone "url to your repo"`
- Create a new branch for your modifications by running `git checkout -b new-branch`
- Add your files with `git add -A`, commit `git commit -s -m "This is my commit message"` and push `git push origin new-branch`.
- Create a `pull request` for the project you want to contribute.

#### Pull Request Template

When you submit a PR, you'll be presented with a PR template that looks
something like this:

```{literalinclude} pull_request_template.txt
```

#### Pull Request Acceptance Criteria

- At least two approvals from reviewers

- All detected status checks pass

- All conversations solved

- Third-party dependency license compatible

#### Pull Request Status Checks Overview

The OPEA projects use GitHub Action for CI test.

| Test Name          | Test Scope                                | Test Pass Criteria |
|--------------------|-------------------------------------------|--------------------|
| DCO                | Use `git commit -s` to sign off           | PASS               |
| Code Format Scan   | pre-commit.ci [Bot]                       | PASS               |
| Code Security Scan | Bandit/Hadolint/Dependabot/CodeQL/Trellix | PASS               |
| Unit Test          | Unit test under test folder               | PASS               |
| End to End Test    | End to end test workflow                  | PASS               |

- [Developer Certificate of Origin (DCO)](https://en.wikipedia.org/wiki/Developer_Certificate_of_Origin), the PR must agree to the terms of Developer Certificate of Origin by signing off each of commits with `-s`, e.g. `git commit -s -m 'This is my commit message'`.
- Unit Test, the PR must pass all unit tests and without coverage regression.
- End to End Test, the PR must pass all end to end tests.

#### Pull Request Review
You can add reviewers from [the code owners list](../codeowner.md) to your PR.

## Support

- Feel free to reach out to [OPEA maintainers](mailto://info@opea.dev) for support.
- Submit your questions, feature requests, and bug reports to the GitHub issues page.

## Contributor Covenant Code of Conduct

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).
