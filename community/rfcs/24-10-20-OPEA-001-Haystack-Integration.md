# 24-10-20-OPEA-001-Haystack-Integration

## Author

[gadmarkovits](https://github.com/gadmarkovits)

## Status

Under Review

## Objective

Create a Haystack integration for OPEA that will enable the use of OPEA components within a Haystack pipeline.

## Motivation

Haystack is a production-ready open source AI framework that is used by many AI practitioners. It has over 70 integrations with various GenAI components such as document stores, model providers and evaluation frameworks from companies such as Amazon, Microsoft, Nvidia and more. Creating an integration for OPEA will allow Haystack customers to use OPEA components in their pipelines. This RFC is used to present a high-level overview of the Haystack integration. 

## Design Proposal

The idea is to create thin wrappers for OPEA components that will enable communicating with them using the existing REST API. The wrappers will match Haystack's API so that they could be used within Haystack pipelines. This will allow developers to seamlessly use OPEA components alongside other Haystack components.

The integration will be implemented as a Python package (similar to other Haystack integrations). The source code will be hosted in OPEA's GenAIComps repo under a new directory called Integrations. The package itself will be uploaded to [PyPi](https://pypi.org/) to allow for easy installation.                 

Following a discussion with Haystack's technical team, it was agreed that a ChatQnA example, using this OPEA integration, would be a good way to showcase its capabilities. To support this, several component wrappers need to be implemented in the first version of the integration (other wrappers will be added gradually):

1. OPEA Document Embedder

    This component will receive a Haystack Document and embed it using an OPEA embedding microservice.

2. OPEA Text Embedder

    This component will receive text input and embed it using an OPEA embedding microservice.

3. OPEA Generator

    This component will receive a text prompt and generate a reponse using an OPEA LLM microservice.

4. OPEA Retriever

    This component will receive an embedding and retrieve documents with similar emebddings using an OPEA retrieval microservice. 

## Alternatives Considered

n/a

## Compatibility

n/a

## Miscs

Once implemented, the Haystack team list the OPEA integration on their [integrations page](https://haystack.deepset.ai/integrations) which will allow for easier discovery. Haystack, in collaboration with Intel, will also publish a technical blog post showcasing a ChatQnA example using this integration (similar to this [NVidia NIM post](https://haystack.deepset.ai/blog/haystack-nvidia-nim-rag-guide)).


