# 24-10-02-GenAIExamples-xxx-Image_and_Audio_Support_in_MultimodalQnA

## Author(s)

[Mustafa Cetin](https://github.com/MSCetin37)
[Melanie Buehler](https://github.com/mhbuehler)
[Dina Jones](https://github.com/dmsuehir)

## Status

Under review

## Objective

The [MultimodalQnA](https://github.com/opea-project/GenAIExamples/tree/main/MultimodalQnA) megaservice in
[GenAIExamples](https://github.com/opea-project/GenAIExamples) currently supports text queries with a response based on
the context derived from collection of videos. This RFC expands upon that and proposes the addition of images, images
with text, and audio data types for both the ingested data and the user query.

## Motivation

As the [Multimodal RAG RFC](https://github.com/opea-project/docs/blob/01597aabeaf4c5d171bdc8cd9f7bccdd9e64f697/community/rfcs/MM-RAG-RFG.md)
explains, enterprises use multimodal data and the proposed enhancement will increase the variety of use cases that the
MultimodalQnA example will be able to support.

<!-- TODO: Update use cases -->
Expanding on the types of supported data types will enable use cases such as:
1. QnA with all of your media using voice only (query and output) 
1. QnA with speech audio files (e.g. podcasts) 
1. QnA with labeled images (e.g. medical use case) 
1. QnA with multimodal PDFs 
1. Trimodal QnA with image, audio, and text 
1. Support for slides

## Design Proposal

There are two phases in the MultimodalQnA example that need to be considered:
* Data ingestion and prep
* User query

### Data Ingestion and Prep

In the data ingestion and prep phase, a collection of data is built up to context for the subsequent queries. From a
user's perspective, they will be able to upload:
* Videos with spoken audio (already supported)
* Videos without spoken audio (already supported)
* Videos with transcriptions (already supported)
* Images with text (proposed)
* Images without text (proposed)
* Spoken audio files (proposed)
* PDF files (proposed)

The [BridgeTower model](https://huggingface.co/BridgeTower/bridgetower-large-itm-mlm-gaudi) which is already utilized
by MultimodalQnA merges visual and text data into a unified semantic space. As it works today, the videos being ingested
are preprocessed into a list of frames and their corresponding transcript or captions that were generated based on the
video. Those frames and their metadata are stored in the vector store, which is used as context for the user's queries.
The addition of image and text are analogous to the video frames and transcripts. With some changes to data prep, the
image and text data could be added to the vector store. Similarly, PDF files can be though of as another form of images
and text. Spoken audio files can be translated to text with using the whisper model, similar to how videos with spoken
audio use the whisper model to generate transcripts for the video. This means that although the user will be able to
upload several different forms of media, once it gets to the embedding model it is all images and text.

<!-- TODO: Document specific component changes and add diagram -->

### User Query

After the vector database has been populated, the user can then submit a query to the MultimodalQnA megaservice. From
the user's perspective, the query can be:
* Text (already supported)
* Spoken audio files (proposed)
* Image and text (proposed)

The [ASR microservice](https://github.com/opea-project/GenAIComps/blob/main/comps/asr/whisper/README.md) which uses the
whisper convert speech to text provides a clear line of sight for adding support for spoken audio queries. Once the
audio has been converted to text, submitting the query would be no different hwo the text queries work today.

<!-- 
TODO: 

- Investigate how image/text queries would work
- Also, how does supporting different data types affect the gateway?
- Diagram
-->


### UI

<!-- TODO: UI considerations and design -->

## Alternatives Considered

<!-- 
TODO: Write up alternate options like creating a seperate examples so that the MultimodalQnA megaservice doesn't get too overloaded.
Also, alternative UI designs?
-->

## Compatibility

list possible incompatible interface or workflow changes if exists.

## Miscellaneous

List other information user and developer may care about, such as:

- Performance Impact, such as speed, memory, accuracy.
- Engineering Impact, such as binary size, startup time, build time, test times.
- Security Impact, such as code vulnerability.
- TODO List or staging plan.

<!--
TODO:
- List considerations like the number of containers, how many HPUs will be needed before/after the the change, etc
- Development phases
-->
