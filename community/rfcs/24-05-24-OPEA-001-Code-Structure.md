# 24-05-24 OPEA-001 Code Structure

## Author

[ftian1](https://github.com/ftian1), [lvliang-intel](https://github.com/lvliang-intel), [hshen14](https://github.com/hshen14)

## Status

Under Review

## Objective

Define a clear criteria and rule of adding new codes into OPEA projects.

## Motivation

OPEA project consists of serveral repos, including GenAIExamples, GenAIInfra, GenAICompos, and so on. We need a clear definition on where the new code for a given feature should be put for a consistent and well-orgnized code structure.


## Design Proposal

The proposed code structure of GenAIInfra is:

```
GenAIInfra/
├── kubernetes-addon/        # the folder implementing additional operational capabilities to Kubernetes applications
├── microservices-connector/ # the folder containing the implementation of microservice connector on Kubernetes
└── scripts/
```

The proposed code structure of GenAIExamples is:

```
GenAIExamples/
└── ChatQnA/
    ├── kubernetes/
    │   ├── manifests
    │   └── microservices-connector
    ├── docker/
    │   ├── docker_compose.yaml
    │   ├── dockerfile
    │   └── chatqna.py
    ├── chatqna.yaml    # The MegaService Yaml
    └── README.md
```

The proposed code structure of GenAIComps is:

```
GenAIComps/
└── comps/
    └── llms/
        ├── text-generation/
        │   ├── tgi-gaudi/
        │   │   ├── dockerfile
        │   │   └── llm.py
        │   ├── tgi-xeon/
        │   │   ├── dockerfile
        │   │   └── llm.py
        │   ├── vllm-gaudi
        │   ├── ray
        │   └── langchain
        └── text-summarization/
```

## Miscs

n/a
