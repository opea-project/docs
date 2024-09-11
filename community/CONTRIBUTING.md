# Contribution Guidelines

Thanks for considering contributing to OPEA project. The contribution process is similar with other open source projects on Github, involving an amount of open discussion in issues and feature requests between the maintainers, contributors and users.


## All The Ways To Contribute

### Contribute a GenAIComponent

1. Local Dev Environment setting? 

2. Navigate to [OPEA GenAIComps](https://github.com/opea-project/GenAIComps) and locate the component folder your integration belongs to. If the microservice type already exists, review the [OPEA microservice API](https://opea-project.github.io/0.9.99/developer-guides/OPEA_API.html#opea-micro-service-api) and follow it in your implementation. Otherwise, if you are contributing a brand new microservice type, you need to define and contribute the API specifications. Consider starting with an RFC.

3. Follow the folder structure in the TEI embedding example below:
  - `embedding_tei.py`: This file defines and registers the microservice. It serves as the entrypoint of the Docker container. Refer to [asr-comp] for a simple example or [tgi-llm] for a more complete example that required adapting to OpenAI API
  - `requirements.txt`: This file is used by Docker to install the necessary dependencies.
  - `Dockerfile` and optionally `docker_compose_yaml`: These files are used to generate the service container image. **Once PR is merged the imaged can be pushed to Hub. Handled by maintainer or vendor/library contrirbutors?**. If your Dockerfile is hardware specific please make it explicit in the name like `Dokerfile.Intel_hpu`
  - `test_<component_folder_path>.sh` : test should building image, start service, validate microservie, stop and destroy docker. Please refer to an example [link](). 
  - `README.md`: at minimum it should include: microservice description, build and start microservice command, curl command for test with expected output how to run tests.

```
├── comps
│   ├── embeddings
│   │   ├── __init__.py
│   │   └── tei     #vendor name or serving framework name
│   │       ├── langchain
│   │       │   ├── docker_compose_embedding.yaml  #could be multiple for different HW
│   │       │   ├── Dockerfile        # could be multiple for different HW
│   │       │   ├── embedding_tei.py  # definition and registration of microservice
│   │       │   ├── README.md
│   │       │   └── requirements.txt
│   │       └── llama_index
│   │           └── . . .
├── tests
│   └── embeddings
│       ├── test_embeddings_tei_langchain.sh    # "test_<folder_path>.sh" filename 
│       └── test_embeddings_tei_llama_index.sh
└── README.md

```
**ths tree doesn't show hardware specific subfolders. do we need them for ci/cd simplicity?** 

4. Now you have created all the required files, and validated your service. Last step is to modify the `README.md` at the component level to list your new component. Now you are ready to file your PR!. 

5. After your component has been merged you are likely interested to build an application with it, and perhaps contributing it also to OPEA! so please continue to the "Contribute a GenAIExample" guide

### Contribute a GenAIExample

All OPEA GenAIExamples can be deployed on a single node with docker compose or on a Kubernetes cluster. When you contribute an example you will need to ensure both deployment paths are supported. If you don't have Kubernetes experience don't fret!, maintainers are available to provide support. **can we say this or is just docker compose minimum requirement?**

- Navigate to [OPEA GenAIExamples]() and check the catalog of examples. If you find one that is very similar to what you are looking for, you can contribute your variation of it to that particular example folder. If you are bringing a completly new application you will need to create a separate example folder. 

- Before stitching together all the microservices to build your application, let's make sure all the required building blocks are available!. You will notice [add link to diagram>]() OPEA uses gateways to handle requests and route them to the corresponding megaservices. If you are just making small changes to the application, like swaping one DB for another, you can reuse the existng Gateway but if you are contributing a completely new application, you will need to add a Gateway class. Navigate to [OPEA GenAIComps Gateway Component](https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/gateway.py) and implement how Gateway should handle requests for your application. **do gateways PR have tests that need to be run, seems not possible on the GenAIComp side????**

- Follow the folder structure in the ChatQA example below:
  - `chatqna.py`: application definition using microservice, megaservice and gateway. There could be multiple .py in the folder based on slight modification of the example application.
  - `example/docker_build_image/build.yaml`: builds necessary images pointing to the Dockerfiles in the GenAIComp repository. 
  - `docker_compose/vendor/device/compose.yaml`: defines pipeline for  docker compose deployment 
  - `kubernetes/vendor/device/manifests/chatqna.yaml`: (required?) will be used for K8s deployemnt
  - `kubernetes/vendor/device/gmc/chatqna.yaml`: (optional) will be used for deployment with GMC
  - `tests\test_compose.sh, test_manifest.sh, test_gmc.sh`: at minimum you need to provide an E2E test with docker compose. if you are contritbutng K8s manifests and GMC yaml, you should also provide test script for those.
  - `ui`: **is this optional or required?**
  - `assets`: nice to have an application flow diagram

```
├── assets
├── benchmark     # optional
├── chatqna.py    # Main application definition (microservices, megaservice, gateway). 
├── chatqna.yaml  # starting v1.0 used to generate manifests for k8s. Keep? 
├── docker_compose
│   ├── intel
│   │   ├── cpu
│   │   │   ├── aipc
│   │   │   │   ├── compose.yaml
│   │   │   │   └── README.md 
│   │   │   └── xeon
│   │   │       ├── compose.yaml
│   │   │       ├── README.md 
│   │   │       └── set_env.sh #optional or required? export env variables, sometimes in README
│   │   └── hpu
│   │       └── gaudi
│   │           ├── compose.yaml
│   │           ├── how_to_validate_service.md    #optional
│   │           ├── README.md
│   │           └── set_env.sh
│   └── nvidia
│       └── gpu   #require device subfolder??
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
│   │   │       │   ├── chatQnA_dataprep_xeon.yaml  # are these different flavors too?  
│   │   │       │   ├── chatQnA_switch_xeon.yaml
│   │   │       │   └── chatQnA_xeon.yaml
│   │   │       └── manifest
│   │   │           └── chatqna.yaml     # could be multiple .yaml for various applications
│   │   └── hpu
│   │       └── gaudi
│   │           ├── gmc
│   │           │   ├── chatQnA_dataprep_gaudi.yaml
│   │           │   ├── chatQnA_gaudi.yaml
│   │           │   └── chatQnA_switch_gaudi.yaml
│   │           └── manifest
│   │               └── chatqna.yaml
│   ├── amd
│   │   ├── cpu      #require device subfolder??
│   │   │   ├── gmc
│   │   │   └── manifest
│   │   └── gpu
│   │       ├── gmc
│   │       └── manifest
│   ├── README_gmc.md    #K8s quickstar
│   └── README.md #docker pull, env set, curl # example quickstart
├── README.md
├── tests
│   ├── test_compose_on_gaudi.sh  #could be more tests for different flavors of the app
│   ├── test_compose_on_xeon.sh
│   ├── test_gmc_on_gaudi.sh
│   ├── test_gmc_on_xeon.sh
│   ├── test_manifest_on_gaudi.sh
│   └── test_manifest_on_xeon.sh
└── ui
    ├── docker
    │   ├── Dockerfile
    │   └── Dockerfile.react
    ├── react
    └── svelte
```


#### Additional steps if your contribution is Hardware Specific

You will need additional step to configure CI/CD for merging your GenAIComp or GenAIExample. 
- Connect hardware into OPEA GHA as self-hosted runner 
#- Contribute new test scripts for the new hardware:
#- Dockerfile for the Component (i,e GenAIComp/comps/llm/text-generation/tgi/docker/Dockerfile_Intel_HPU
#- Update image build yaml for new images​
- Update CI/CD workflow to identify and deploy new test
OPEA maintainer [suyue git handle]() can assist with this. 

### Community Discussions

Developers are encouraged to participate in discussions by opening an issue in one of the GitHub repos at https://github.com/opea-project. Alternatively, they can send an email to [info@opea.dev](mailto:info@opea.dev) or subscribe to [X/Twitter](https://twitter.com/opeadev) and [LinkedIn Page](https://www.linkedin.com/company/opeadev/posts/?feedView=all) to get latest updates about the OPEA project.

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
  - If the PR introduces new microservice for `GenAIComps`, the PR must include new end to end tests. The test script name should match with the folder name so the test will be automatically triggered by test structure, for examples, if the new service is `GenAIComps/comps/dataprep/redis/langchain`, then the test script name should be `GenAIComps/tests/test_dataprep_redis_langchain.sh`.
  - If the PR introduces new example for `GenAIExamples`, the PR must include new example end to end tests. The test script name should match with the example name so the test will be automatically triggered by test structure, for examples, if the example is `GenAIExamples/ChatQnA`, then the test script name should be `ChatQnA/tests/test_chatqna_on_gaudi.sh` and `ChatQnA/tests/test_chatqna_on_xeon.sh`.

#### Pull Request Review
You can add reviewers from [the code owners list](../codeowner.md) to your PR.

## Support

- Feel free to reach out to [OPEA maintainers](mailto: info@opea.dev) for support.
- Submit your questions, feature requests, and bug reports to the GitHub issues page.

## Contributor Covenant Code of Conduct

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).
