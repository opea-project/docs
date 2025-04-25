# OPEA Release Guide

## Release Cadence

The following release cadence is for year 2024/2025. Please note that the dates listed below may not reflect the most up-to-date information. 

| Version | Release Date |
|---------|--------------|
| 0.1     | Apr 2024     |
| 0.6     | May 2024     |
| 0.7     | Jun 2024     |
| 0.8     | Jul 2024     |
| 0.9     | Aug 2024     |
| 1.0     | Sep 2024     |
| 1.1     | Nov 2024     |
| 1.2     | Jan 2025     |
| 1.3     | Apr 2025     |
| 1.4     | Jul 2025     |
| 1.5     | Oct 2025     |
| 1.6     | Jan 2026     |
| 1.7     | Apr 2026     |

## General Overview

Releasing a new version of OPEA generally involves the following key steps:

1. Feature freeze (2 weeks before the release)
2. Code/Doc freeze, and creating the RC(Release Candidate) branch (1 week before the release)
3. Cherry Pick critical Code/Doc fix from main branch to the RC branch
4. Create release tag from RC branch
5. Deliver docker images, helm charts, and pypi binaries 

## Feature Freeze

Generally, this marks a point in the OPEA release process where no new features are added to the `main` branch of OPEA projects. It typically occurs two weeks before the scheduled OPEA release. After this point, first round release test will be triggered. 

## Code/Doc Freeze, and Creating the RC Branch

This is the point in the OPEA release cycle to create the Release Candidate (RC) branch. It typically occurs one week before the scheduled OPEA release. After this point, final round release test will be triggered.

### Preparing Creating RC Branch
Following requirements needs to be met prior to creating the RC branch:
- Implement all features and functionalities targeting this release.
- Resolve all the known outstanding issues targeting this release.
- Fix all the bugs found in the release test.

### Creating RC Branch
The RC branch are typically created from the `main` branch. The branch name must follow the following format: 
```
v{MAJOR}.{MINOR}rc
```
An example of this would look like:
```
v1.1rc
```

## Cherry Pick Critical Code/Doc Fix
Fixes for critical issues after code freeze must cherry-pick into the RC branch.

### How to do Cherry Picking
Critical issues found in the RC branch must be fixed in the `main` branch and then cherry-picked into the RC branch. Cherry-picking will be done manually by the CI/CD owner. 

## Creating Tag from RC Branch
The following requirements need to be met prior to creating final Release Candidate:
- No outstanding issues in the milestone. 
- No open issues/PRs marked with the milestone of this release(e.g. v1.1).
- All the closed milestone PRs should be contained in the release branch.
- Create tags with [GHA job](https://github.com/opea-project/Validation/actions/workflows/manual-create-tag.yaml). 

## Deliver Docker Images, Helm Charts, and PyPi Binaries
After the release tag is created, the following artifacts need to be delivered:
- Docker images, [GHA job](https://github.com/opea-project/GenAIExamples/actions/workflows/manual-docker-publish.yml).
- Helm charts, [GHA job](https://github.com/opea-project/GenAIInfra/actions/workflows/manual-release-charts.yaml).
- PyPi binaries, [GHA job](https://github.com/opea-project/Validation/actions/workflows/manual-pypi-publish.yml).
