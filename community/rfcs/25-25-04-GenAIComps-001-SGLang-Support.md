# Support SGLang in OPEA

 

This RFC is for supporting SGLang as one of the inference engine in OPEA.

 

## Author(s)

 

[<gooxidalao>](<(https://github.com/gooxidalao?tab=repositories)>)

 

## Status

 

`Under Review`

 

## Objective

 

SGLang is a fast serving framework for large language models and vision language models. It makes your interaction with models faster and more controllable by co-designing the backend runtime and frontend language, while achieving higher throughput than competitive solution. Supporting SGLang in OPEA provides user with a faster and more efficient option to interact with the large language models.

 

This RFC discusses about why and how shall we add SGLang as one of the inference backends in OPEA.

 

## Motivation

 

SGLang's Python-based DSL frontend and highly optimized backend enable fast inference and structured output generation, making it a powerful tool for efficient execution of large language model programs. OPEA as a framework that harnesses the best innovations across the ecosystem shall adopt the engine to provide user with more options.

 

## Design Proposal

 

The proposed code structure for SGLang is:

 

```

GenAIComps/

├── third_parties/

      └── sglang/             # the folder containing the deployment file and docker script

   ├── README.md

        ├── deployment/

         └── src/

```

 

## Compatibility

 

n/a.

 

## Miscellaneous

 

List other information user and developer may care about, such as:

 

- Engineering Impact:

  - provide one extra option for inference engine
