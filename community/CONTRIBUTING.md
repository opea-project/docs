# Contribution Guidelines

Thanks for considering contributing to OPEA project. The contribution process is similar with other open source projects on Github, involving an amount of open discussion in issues and feature requests between the maintainers, contributors and users.


## Table of Contents

<!-- toc -->

- [All The Ways to Contribute](#all-the-ways-to-contribute)
  - [Community Discussions](#community-discussions)
  - [Documentations](#documentations)
  - [Reporting Issues](#reporting-issues)
  - [Proposing New Features](#proposing-new-features)
  - [Submitting Pull Requests](#submitting-pull-requests)
    - [Create Pull Request](#create-pull-request)
    - [Pull Request Checklist](#pull-request-checklist)
    - [Pull Request Template](#pull-request-template)
    - [Pull Request Acceptance Criteria](#pull-request-acceptance-criteria)
    - [Pull Request Status Checks Overview](#pull-request-status-checks-overview)
    - [Pull Request Review](#pull-request-review)
- [Support](#support)
- [Contributor Covenant Code of Conduct](#contributor-covenant-code-of-conduct)

<!-- tocstop -->

## All The Ways To Contribute

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

- Follow the [RFC Template](./rfc_template.md) to propose your idea.
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

See [PR template](./pull_request_template.md)

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
