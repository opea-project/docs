# 24-10-02-GenAIExamples-xxx-Image_and_Audio_Support_in_MultimodalQnA

## Author(s)

[Melanie Buehler](https://github.com/mhbuehler), [Mustafa Cetin](https://github.com/MSCetin37), [Dina Jones](https://github.com/dmsuehir)

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

Expanding on the types of supported data types will enable use cases such as:
1. **Voice Query and Response**: A user wants to query and chat with a multimodal data store using speech as input and get responses returned as speech audio output. Supporting this use case would make the application more accessible to those who cannot see or read and safer for those who are driving a vehicle.
1. **QnA with Speech Audio Files**: A user wants to query and chat with a collection of audio files, such as a podcast library.
1. **QnA with Captioned/Labeled Images**: A user would like to populate the database with images that have labels, such as "normal" and “abnormal” radiology images, or user-provided captions, like radiologist's notes, and then query with a new image to find similar ones. After retrieving the most similar image, the system could predict the new image's label (i.e. assist with diagnosis).
1. **QnA with Multimodal PDFs**: A user wants to query and chat with the contents of one or more PDF files, like books, journal articles, business reports, or travel brochures. The PDFs could contain images with or without captions and charts that include titles and descriptions. 

## Design Proposal

There are two phases in the MultimodalQnA example that need to be considered:
* Data ingestion and prep
* User query

Both of these phases are affected by the enhancements in this RFC. The design for expanding the types of multimodal data
for [data ingestion](#data-ingestion-and-prep) and [user queries](#user-query) are outlined in the next couple of
sections.

There is also a Gradio user interface (UI) that allows the user to both upload data for ingestion and submit queries
based on the context in the database. The introduction of different data types will affect the UI design, and the
proposed changes are discussed in the [UI section](#ui) below.

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
are preprocessed into a list of frames with their corresponding transcript or captions that were generated based on the
video. Those frames and their metadata are stored in the vector store, which is used as context for the user's queries.
The addition of image and text are analogous to the video frames and transcripts. With some changes to data prep, the
image and text data could be added to the vector store. Similarly, PDF files can be thought of as another form of images
and text. Spoken audio files can be translated to text with using the whisper model, similar to how videos with spoken
audio use the whisper model to generate transcripts for the video. This means that although the user will be able to
upload several different forms of media, once it gets to the embedding model it is all images and text.

The table below lists the endpoints for the multimodal data prep microservice that will be changing with this proposal.

| Endpoint | Data type | Description |
|----------|-----------|-------------|
| `6007:/v1/videos_with_transcripts` becomes `6007:/v1/ingest_with_transcripts` | Videos with transcripts and images with text | For video with transcripts, gets the video file with their corresponding transcript file (.vtt), and then extracts frames and saves annotations. The image with text would be treated like a single frame with transcript. The data and metadata are prepared for ingestion and then added to the Redis vector store. |
| `6007:/v1/generate_transcripts` | Videos with spoken audio and audio only | For videos with spoken audio, data prep extracts the audio from the video and then generates a transcript (.vtt) using the whisper model. For audio only, the transcript would also be generated using the whisper model. The data and metadata are prepared for ingestion and then added to the Redis vector store. |
| `6007:/v1/generate_captions` | Videos without spoken audio (i.e. background music, silent movie) and images without text | For videos, data prep extracts frames from the video and uses the LVM microservice to generate captions for the frames. An image will be treated similarly to a video frame, and the LVM will be used to generate a caption for the image. The data and metadata are prepared for ingestion and then added to the Redis vector store. |
| `6007:/v1/dataprep/get_videos` becomes `6007:/v1/dataprep/get_mm_data` |  Multimodal | Lists names of uploaded multimodal data. |
| `6007:/v1/dataprep/delete_videos` becomes `6007:/v1/dataprep/delete_mm_data` |  Multimodal | Deletes all the uploaded multimodal data. |

> TODO: Document specific component changes and add diagram


### User Query

After the vector database has been populated, the user can then submit a query to the MultimodalQnA megaservice. From
the user's perspective, the query can be:
* Text (already supported)
* Spoken audio files (proposed)
* Image and text (proposed)

The [ASR microservice](https://github.com/opea-project/GenAIComps/blob/main/comps/asr/whisper/README.md) which uses the
whisper convert speech to text provides a clear line of sight for adding support for spoken audio queries. Once the
audio has been converted to text, submitting the query would be no different how the text queries work today.

Changes to the user query flow will involve the following components:
* The multimodal gateway
* The embedding mircoservice

The details explaining the specific changes to these components are explained in the sections below.

### MultimodalGateway

Currently, the [MultimodalGateway](https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/gateway.py#L688)
class analyzes the input message from the request coming in to determine if it's a first query or a follow up query.
Initial queries have a single prompt string, whereas follow up queries have a list of prompts and images.

When introducing different types of data for user queries, we will need to change the inital query from a string to a
dictionary in order to comprehend data type and handle multiple items (image and text).



> TODO: 
> - Investigate how image/text queries would work
> - Also, how does supporting different data types affect the gateway?
> - Diagram

### UI

> TODO: UI considerations, design, and mock up

## Alternatives Considered

> TODO: Write up alternate options like creating a seperate examples so that the MultimodalQnA megaservice doesn't get too overloaded.
> Also, alternative UI designs?

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
