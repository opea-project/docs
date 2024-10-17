.. _OPEA_API:

OPEA API Service Spec (v1.0)
############################

Authors:

.. rst-class:: rst-columns

* feng.tian@intel.com
* liang1.lv@intel.com
* haihao.shen@intel.com
* kaokao.lv@intel.com

This specification is used to define the Restful API of OPEA Mega
Service for users to access, as long as the input and output definition
of all OPEA Micro Services for developer to build OPEA Mega service.

.. note:: This API Service Specification is a work-in-progress and may be
   incomplete and contain errors.

.. contents:: API Services Table of Contents
   :depth: 2
   :local:

-----

OPEA Mega Service API
*********************

OPEA Mega Service is the main entry user can access for a prebuilt GenAI
application. Such GenAI application consists of single or several OPEA
Micro Services chained as a DAG (Directed Acyclic Graph) and built as an
execution workflow for developer to create complex applications.

-----

.. _list_services:

List Services
=============

List all supported services by the OPEA Mega Service.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **GET**
     - ``/v1/list_service``

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             <service_name>: <service_description>
          }

       ``service_name (string)``
         The endpoints or URLs OPEA mega service is serving. For example,
         ``/v1/RAG``.

         Note some keywords such as ``/v1/audio/speech``,
         ``/v1/audio/transcriptions``, ``/v1/embeddings``,
         ``/v1/chat/completions`` are reserved for openAI compatible Mega
         Service.

       ``service_description (string)``
         The detail usage description user used to access the specified
         endpoints or urls OPEA mega service is serving, including the request
         and post format and details.
   * - **405**
     - ``{"error": "Retrieve service name wrongly."}``

-----

List Configurable Parameters
============================

List all configurable parameters for users to control the behavior of
the OPEA Mega Service.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **GET**
     - ``/v1/list_parameters``

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             <micro_service_name>:
             {
                <parameter_name>: data_type,
                . . .
             }
          }

       ``micro_service_name (string)``
         The micro service name in OPEA mega service in which some parameters
         are configurable.

       ``parameter_name (string)``
         The configurable parameter name in OPEA mega service.

       ``data_type (string)``
         The supported data type: ``"string"`` or ``"integer"``.

       For example: ``{"/v1/llm_generate": {"max_tokens": "integer"}}``
   * - **405**
     - ``{"error": "Retrieve configurable parameter wrongly."}``

-----

Embedding
=========

**Optional**. Only exists if a single OPEA microservice which exposes
``/micro_service/embedding`` interface is built as OPEA Mega service.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **POST**
     - ``/v1/list_parameters``

.. list-table::
   :header-rows: 1

   * - Type
     - Parameters
     - Values
     - Required
     - Description
   * - **POST**
     - ``input``
     - ``string``
     - required
     - Input text to embed, encoded as a string or array of tokens. To embed
       multiple inputs in a single request, pass an array of strings or array of
       token arrays. The input must not exceed the max input tokens for the
       model (8192 tokens for text-embedding-ada-002), cannot be an empty
       string, and any array must be 2048 dimensions or less.
   * - **POST**
     - ``model``
     - ``string``
     - deprecated
     - The ID of the model to use.
   * - **POST**
     - ``encoding_format``
     - ``string``
     - required
     - The format to return the embeddings in. Can be either ``"float"`` or ``"base64"``.
   * - **POST**
     - ``dimensions``
     - ``integer``
     - optional
     - The number of dimensions the resulting output embeddings should have.
       Only supported in text-embedding-3 and later models.

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             "object": "list",
             "data": [{
                "object": "embedding",
                "embedding": [
                   0.0023064255,
                   ...
                ],
                "index": 0
             }],
             "model": "text-embedding-ada-002",
             "usage": {
                "prompt_tokens": 8,
                "total_tokens": 8
             },
          }


       ``embedding (float)``
         The vector representation for given inputs.

       ``index (integer)``
         The index of the embedding in the list of embeddings.

       ``parameter_name (string)``
         The configurable parameter name in OPEA mega service.

       ``data_type (string)``
         The supported data type, ``"string"`` or ``"integer"``.

       For example: ``{"llm": {"max_tokens": "integer"}}``
   * - **405**
     - ``{"error": "Retrieve configurable parameter wrongly."}``

-----

Chat
====

**Optional**. . If a OPEA Mega service is built with this request url, it complies with below format.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **POST**
     - ``/v1/chat/completions``

.. list-table::
   :header-rows: 1

   * - Type
     - Parameters
     - Values
     - Required
     - Description
   * - **POST**
     - ``message``
     - ``array``
     - required
     - A list of messages comprising the conversation. Refer to the
       `detail format <https://platform.openai.com/docs/api-reference/chat/create#chat-create-messages>`_.
   * - **POST**
     - ``model``
     - ``string``
     - deprecated
     - The ID of the model to use.
   * - **POST**
     - ``frequency_penalty``
     - ``integer``
     - optional
     - Number between -2.0 and 2.0. Positive values penalize new tokens based on
       their existing frequency in the text so far, decreasing the model's
       likelihood to repeat the same line verbatim.
   * - **POST**
     - ``logit_bias``
     - ``map``
     - optional
     - Modify the likelihood of specified tokens appearing in the completion.
       Accepts a JSON object that maps tokens (specified by their token ID in
       the tokenizer) to an associated bias value from -100 to 100.
       Mathematically, the bias is added to the logits generated by the model
       prior to sampling. The exact effect will vary per model, but values
       between -1 and 1 should decrease or increase likelihood of selection;
       values like -100 or 100 should result in a ban or exclusive selection of
       the relevant token.
   * - **POST**
     - ``logprobs``
     - ``bool``
     - optional
     -
   * - **POST**
     - ``top_logprobs``
     - ``integer``
     - optional
     -
   * - **POST**
     - ``max_tokens``
     - ``integer``
     - optional
     -
   * - **POST**
     - ``n``
     - ``integer``
     - optional
     -
   * - **POST**
     - ``presence_penalty``
     - ``float``
     - optional
     -
   * - **POST**
     - ``response_format``
     - ``object``
     - optional
     -
   * - **POST**
     - ``seed``
     - ``integer``
     - optional
     -
   * - **POST**
     - ``stop``
     - ``string``
     - optional
     -
   * - **POST**
     - ``stream``
     - ``bool``
     - optional
     -
   * - **POST**
     - ``stream_options``
     - ``object``
     - optional
     -
   * - **POST**
     - ``temperature``
     - ``float``
     - optional
     -
   * - **POST**
     - ``top_p``
     - ``float``
     - optional
     -
   * - **POST**
     - ``tools``
     - ``array``
     - optional
     -
   * - **POST**
     - ``tool_choice``
     - ``string``
     - optional
     -
   * - **POST**
     - ``user``
     - ``string``
     - optional
     -

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             "id": "chatcmpl-123",
             "object": "chat.completion",
             "created": 1677652288,
             "model": "gpt-3.5-turbo-0125",
             "system_fingerprint": "fp_44709d6fcb",

             "choices": [{
                "index": 0,
                "object": "embedding", 
                "message": {
                   "role": "assistant", 
                   "content": "\n\nHello there, how may I assist you today?",
                },
                "logprobs": null,
                "finish_reason": "stop",
             }],

             "usage": {
                "prompt_tokens": 9,
                "completion_tokens": 12,
                "total_tokens": 21
             },
          }


       ``id (string)``
         A unique identifier for the chat completion.

       ``choices (array)``
         A list of chat completion choices. Can be more than one if ``n`` is greater than 1.

       ``created (integer)``
         The Unix timestamp (in seconds) of when the chat completion was created.

       ``model (string)``
         The model used for the chat completion.

       ``system_fingerprint (string)``
         This fingerprint represents the backend configuration that the model
         runs with. Can be used in conjunction with the seed request parameter to
         understand when backend changes have been made that might impact
         determinism.

       ``object (string)``
         The object type, which is always ``"chat.completion"``.

       ``usage (object)``
         Usage statistics for the completion request.

-----

Other Operations
================

Check the usage description returned in :ref:`list_services` to know what other
operations are supported by this OPEA Mega Service.

OPEA Micro Service API
**********************

OPEA Micro Service is the building block of constructing any GenAI applications.
The API in OPEA micro service is used by developers to construct OPEA Mega
Service like a DAG chain and is invisible for end user.

Embedding Micro Service
=======================

The micro service is used to generate a vector representation of a given input.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **POST**
     - ``/v1/embeddings``

.. list-table::
   :header-rows: 1

   * - Type
     - Parameters
     - Values
     - Required
     - Description
   * - **POST**
     - ``input``
     - ``string``
     - required
     - Input text to embed, encoded as a string or array of tokens. To
       embed multiple inputs in a single request, pass an array of strings or
       array of token arrays. The input must not exceed the max input tokens for
       the model (8192 tokens for text-embedding-ada-002), cannot be an empty
       string, and any array must be 2048 dimensions or less
   * - **POST**
     - ``model``
     - ``string``
     - required
     - The ID of the model to use.
   * - **POST**
     - ``encoding_format``
     - ``string``
     - optional
     - The format to return the embeddings in. Can be either ``"float"`` or
       ``"base64"``. Devault to ``"float"``.
   * - **POST**
     - ``dimensions``
     - ``integer``
     - optional
     - The number of dimensions the resulting output embeddings should have. 
   * - **POST**
     - ``user``
     - ``string``
     - optional
     - A unique identifier representing your end-user, which can help OpenAI to
       monitor and detect abuse.

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             "object": "list",
             "data": [{
                "object": "embedding",
                "embedding": [
                   0.0023064255,
                   -0.009327292,
                   . . . (1536 floats total for ada-002)
                   -0.0028842222,
                ],
                "index": 0
             }],
             "model": "text-embedding-ada-002",
             "usage": {
                "prompt_tokens": 8,
                "total_tokens": 8
             },
          }


       ``embedding (list of float)``
         The vector representation for given inputs.
   * - **405**
     - ``{"error": "The request of getting embedding vector fails."}``

-----

LLM Generation Micro Service
============================

The micro service is used to provide LLM generation service.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **POST**
     - ``/v1/chat/completions``

.. list-table::
   :header-rows: 1

   * - Type
     - Parameters
     - Values
     - Required
     - Description
   * - **POST**
     - ``message``
     - ``array``
     - required
     - A list of messages comprising the conversation so far. Example Python code.
   * - **POST**
     - ``model``
     - ``string``
     - required
     - The ID of the model to use. See the model endpoint compatibility table
       for details on which models work with the Chat API.
   * - **POST**
     - ``frequency_penalty``
     - ``float``
     - optional
     - Number between -2.0 and 2.0. Positive values penalize new tokens based on
       their existing frequency in the text so far, decreasing the model's
       likelihood to repeat the same line verbatim.
   * - **POST**
     - ``logit_bias``
     - ``map``
     - optional
     - Modify the likelihood of specified tokens appearing in the
       completion.Accepts a JSON object that maps tokens (specified by their
       token ID in the tokenizer) to an associated bias value from -100 to 100.
       Mathematically, the bias is added to the logits generated by the model
       prior to sampling. The exact effect will vary per model, but values
       between -1 and 1 should decrease or increase likelihood of selection;
       values like -100 or 100 should result in a ban or exclusive selection of
       the relevant token.
   * - **POST**
     - ``logprobs``
     - ``bool``
     - optional
     - Whether to return log probabilities of the output tokens or not. If true,
       returns the log probabilities of each output token returned in the
       content of message.
   * - **POST**
     - ``top_logprobs``
     - ``integer``
     - optional
     - An integer between 0 and 20 specifying the number of most likely tokens
       to return at each token position, each with an associated log
       probability. ``logprobs`` must be set to true if this parameter is used.
   * - **POST**
     - ``max_tokens``
     - ``integer``
     - optional
     - The maximum number of tokens that can be generated in the chat
       completion.The total length of input tokens and generated tokens is
       limited by the model's context length. Example Python code for counting
       tokens.
   * - **POST**
     - ``n``
     - ``integer``
     - optional
     - How many chat completion choices to generate for each input message. Note
       that you will be charged based on the number of generated tokens across
       all of the choices. Keep n as 1 to minimize costs.
   * - **POST**
     - ``presence_penalty``
     - ``float``
     - optional
     -
   * - **POST**
     - ``response_format``
     - ``object``
     - optional
     -
   * - **POST**
     - ``seed``
     - ``integer``
     - optional
     - This feature is in Beta. If specified, our system will make a best effort
       to sample deterministically, such that repeated requests with the same
       seed and parameters should return the same result. Determinism is not
       guaranteed, and you should refer to the ``system_fingerprint`` response
       parameter to monitor changes in the backend.
   * - **POST**
     - ``service_tier``
     - ``string``
     - optional
     - Specifies the latency tier to use for processing the request. This
       parameter is relevant for customers subscribed to the scale tier
       service. If set to ``"auto"``, the system will utilize scale tier credits
       until they are exhausted. If set to ``"default"``, the request will be
       processed using the default service tier with a lower uptime SLA and no
       latency guarentee. When this parameter is set, the response body will
       include the ``service_tier`` utilized.
   * - **POST**
     - ``stop``
     - ``string``
     - optional
     - Up to 4 sequences where the API will stop generating further tokens.
   * - **POST**
     - ``stream``
     - ``bool``
     - optional
     - If set, partial message deltas will be sent, like in ChatGPT. Tokens will
       be sent as data-only server-sent events as they become available, with
       the stream terminated by a data: ``[DONE]`` message. Example Python code.
   * - **POST**
     - ``stream_options``
     - ``object``
     - optional
     - Options for streaming response. Only set this when you set ``"stream": "true"``.
   * - **POST**
     - ``temperature``
     - ``float``
     - optional
     - What sampling temperature to use, between 0 and 2. Higher values like 0.8
       will make the output more random, while lower values like 0.2 will make
       it more focused and deterministic. We generally recommend altering this or
       ``top_p`` but not both.
   * - **POST**
     - ``top_p``
     - ``float``
     - optional
     - An alternative to sampling with temperature, called nucleus sampling,
       where the model considers the results of the tokens with ``top_p``
       probability mass. So 0.1 means only the tokens comprising the top 10%
       probability mass are considered. We generally recommend altering this or
       ``temperature`` but not both.
   * - **POST**
     - ``tools``
     - ``array``
     - optional
     - A list of tools the model may call. Currently, only functions are
       supported as a tool. Use this to provide a list of functions the model
       may generate JSON inputs for. A max of 128 functions are supported.
   * - **POST**
     - ``tool_choice``
     - ``string``
     - optional
     - Controls which (if any) tool is called by the model. ``"none"`` means the model
       will not call any tool and instead generates a message. ``"auto"`` means the
       model can pick between generating a message or calling one or more tools.
       required means the model must call one or more tools. Specifying a
       particular tool via 
       ``{"type": "function", "function": {"name": "my_function"}}`` forces the
       model to call that tool. ``"none"`` is the default when no tools are present.
       ``"auto"`` is the default if tools are present.

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             "id": "chatcmpl-123",
             "object": "chat.completion",
             "created": 1677652288,
             "model": "gpt-4o-mini",
             "system_fingerprint": "fp_44709d6fcb",
             "choices": [{
                "index": 0,
                "object": "embedding", 
                "message": {
                   "role": "assistant", 
                   "content": "\n\nHello there, how may I assist you today?",
                },
                "logprobs": null,
                "finish_reason": "stop",
             }],

             "usage": {
                "prompt_tokens": 9,
                "completion_tokens": 12,
                "total_tokens": 21
             },
          }
   * - **405**
     - ``{"error": "The request of LLM generation fails."}``

-----

ASR Micro Service
=================

The micro service is used to provide audio to text service.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **POST**
     - ``/v1/asr``

.. list-table::
   :header-rows: 1

   * - Type
     - Parameters
     - Values
     - Required
     - Description
   * - **POST**
     - ``url``
     - ``docarray.AudioUrl``
     - optional
     - The link to the audio.
   * - **POST**
     - ``model_name_or_path``
     - ``string``
     - optional
     - The model used to do audio-to-text translation.
   * - **POST**
     - ``Language``
     - ``string``
     - optional
     - The language that model prefer to detect. Default is ``"auto"``.

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             "text": string
          }
   * - **405**
     - ``{"error": "The request of ASR fails."}``

-----

RAG Retrieval Micro Service
===========================

The micro service is used to provide RAG retrieval service. It’s usually after
embedding micro sevice and before RAG reranking micro service to build a RAG
Mega service.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **POST**
     - ``/v1/rag_retrieval``

.. list-table::
   :header-rows: 1

   * - Type
     - Parameters
     - Values
     - Required
     - Description
   * - **POST**
     - ``text``
     - ``string``
     - required
     - The input string to query.
   * - **POST**
     - ``embedding``
     - ``list of float``
     - required
     - The list of float for text as vector representation.

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             "retrieved_docs": list of string,
             "initial_query": string,
             "json_encoders": [{
                "text": "I am the agent of chatbot. What can I do for you?",
             },
             ...
             ]
          }
   * - **405**
     - ``{"error": "The request of ASR fails."}``

-----

RAG Reranking Micro Service
===========================

The micro service is used to provide RAG reranking service. It’s usually after
RAG retrieval and before LLM generation micro service.

Request
-------

.. list-table::
   :header-rows: 1

   * - Method
     - URL
   * - **POST**
     - ``/v1/rag_reranking``

.. list-table::
   :header-rows: 1

   * - Type
     - Parameters
     - Values
     - Required
     - Description
   * - **POST**
     - ``retrieved_docs``
     - ``list of string``
     - required
     - The docs to be retreived.
   * - **POST**
     - ``initial_query``
     - ``string``
     - required
     - The string to query.
   * - **POST**
     - ``json_encoders``
     - ``list of float``
     - required
     - The json encoder used.

Response
--------

.. list-table::
   :header-rows: 1

   * - Status
     - Response
   * - **200**
     - .. code-block::

          {
             "query": string,
             "doc": [{
                "text": "I am the agent of chatbot. What can I do for you?",
             },
             ...
             ]
          }
   * - **405**
     - ``{"error": "The request of ASR fails."}``

