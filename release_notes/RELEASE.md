# Releasing OPEA

## Release Cadence

The following release cadence is for year 2024/2025. Please note that the dates listed below may not reflect the most up-to-date information

| Version | Release Date |
| --- | --- |
| 0.6 | Jun 2024 |
| 0.7 | Jun 2024 |
| 0.8 | Jul 2024 |
| 0.9 | Aug 2024 |
| 1.0 | Sep 2024 |
| 1.1 | Nov 2024 |
| 1.2 | Jan 2025 |
| 1.3 | Mar 2025 |
| 1.4 | May 2025 |
| 1.5 | Jul 2025 |
| 1.6 | Sep 2025 |
| 1.7 | Nov 2025 |

## General Overview

Releasing a new version of OPEA generally involves the following key steps:

1. Feature/Dockerfile Freeze (2 weeks before the release)
2. Code/Doc Freeze, and Creating the RC(Release Candidate) Branch (1 week before the release)
3. Merging Cherry Picks to the RC Branch
4. Creating Tag from RC Branch

## Feature/Dockerfile Freeze

Generally, this marks a point in the OPEA release process where no new features or Dockerfile updates are added to the `main` branch of OPEA projects. It typically occurs two weeks before the scheduled OPEA release.

## Code/Doc Freeze, and Creating the RC Branch

This is the point in the OPEA release process where no code changes or document changes are updated to the `main` branch of OPEA projects. It typically occurs one week before the scheduled OPEA release.

### Preparing Creating RC Branch
Following requirements needs to be met prior to creating the RC branch:
- Implement all features and functionalities targeting this release.
- Resolve all the known outstanding issues targeting this release.
- Validation?? TODO

### Creating RC Branch
The RC branch are typically created from the `main` branch. The branch name must follow the following format: 
```
v{MAJOR}.{MINOR}rc
```
An example of this would look like:
```
v1.1rc
```

## Merging Cherry Picks to the RC Branch
Fixes typically are necessary for bugs and regressions after code freeze. 

### How to do Cherry Picking
TODO

### Cherry Picking Reverts
TODO

## Creating Tag from RC Branch
The following requirements need to be met prior to creating final Release Candidate:
- No outstanding issues in the milestone. No open issues/PRs whose has the milestone of this release(e.g. v1.1).
- All the closed milestone PRs should be present in the release branch.

You can use the following commands to create release tag.
TODO


