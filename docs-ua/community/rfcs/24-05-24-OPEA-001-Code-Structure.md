# 24-05-24 OPEA-001 Code Structure

## Автори

[ftian1](https://github.com/ftian1), [lvliang-intel](https://github.com/lvliang-intel), [hshen14](https://github.com/hshen14)

## Статус

На розгляді

## Мета

Визначити чіткі критерії та правила додавання нових кодів до проектів OPEA.

## Мотивація

Проект OPEA складається з серверних репозиторіїв, включаючи GenAIExamples, GenAIInfra, GenAICompos тощо. Нам потрібне чітке визначення того, куди слід поміщати новий код для певної функції, щоб мати послідовну і добре організовану структуру коду.

## Проєктна пропозиція

Запропонована структура коду GenAIInfra має такий вигляд:

```
GenAIInfra/
├── kubernetes-addon/        # the folder implementing additional operational capabilities to Kubernetes applications
├── microservices-connector/ # the folder containing the implementation of microservice connector on Kubernetes
└── scripts/
```

Запропонована структура коду GenAIExamples має такий вигляд:

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

Запропонована структура коду GenAIComps має такий вигляд:

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
