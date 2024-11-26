# Adding SLMs support for AgentQnA workflow in GenAIExamples on Intel Xeon platform

The AgentQnA workflow in GenAIExamples uses an LLM as an agent to intelligently manage the control flow in the pipeline. 
Currently, it relies on the OpenAI paid API for LLM services on the Xeon platform. 
This RFC aims to add support for open-source small language models (SLMs) locally deployed on Xeon through Ollama.

## Author(s)

Pratool Bharti

## Status

 `Under Review`

## Objective

### Problems This Will Solve

- **Cost Reduction**: Eliminates the need for paid API services by using open-source LLMs.
- **Data Privacy**: Ensures data privacy by processing data locally.
- **Performance Optimization**: Leverages the computational power of Intel Xeon CPUs for efficient LLM execution.

### Goals

- **Local Deployment**: Enable local deployment of open-source LLMs on Intel Xeon CPUs.
- **Integration with Ollama**: Seamlessly integrate Ollama for managing LLMs.
- **Maintain Functionality**: Ensure the AgentQnA workflow continues to function effectively with the new setup.

### Non-Goals

- **Cloud Deployment**: This RFC does not aim to support cloud-based LLM deployment.
- **New Features**: No new features will be added to the AgentQnA workflow beyond the support for local LLMs.
- **Support for Non-Xeon Platforms**: This RFC is specific to Intel Xeon CPUs and does not cover other hardware platforms.

## Motivation

### Cost Efficiency
Reducing reliance on paid API services can significantly lower operational costs.

### Enhanced Data Security
Processing data locally ensures that sensitive information remains secure and private.

### Performance Gains
Utilizing the computational power of Intel Xeon CPUs can lead to faster and more efficient processing.

### Open-Source Flexibility
Open-source LLMs provide greater flexibility and customization options compared to proprietary solutions.

### Related Work
- **Existing Open-Source LLMs**: Projects like GPT-4All and other open-source LLMs provide alternatives to proprietary APIs.
- **Local Deployment Frameworks**: Tools like Ollama facilitate the local deployment and management of LLMs.
- **Previous Implementations**: Other projects may have implemented similar solutions using different hardware or software stacks, providing valuable insights and best practices.

## Design Proposal

This is the heart of the document, used to elaborate the design philosophy and detail proposal.

## Alternatives Considered

List other alternatives if have, and corresponding pros/cons to each proposal.

## Compatibility

list possible incompatible interface or workflow changes if exists.

## Miscellaneous

List other information user and developer may care about, such as:

- Performance Impact, such as speed, memory, accuracy.
- Engineering Impact, such as binary size, startup time, build time, test times.
- Security Impact, such as code vulnerability.
- TODO List or staging plan.
