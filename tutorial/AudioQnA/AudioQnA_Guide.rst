.. _AudioQnA_Guide:

AudioQnA
####################

.. note:: This guide is in its early development and is a work-in-progress with
   placeholder content.

Overview
********

AudioQnA is an example that demonstrates the integration of Generative AI 
(GenAI) models for performing question-answering (QnA) on audio files, with 
the added functionality of Text-to-Speech (TTS) for generating spoken 
responses.The example showcases how to convert audio input to text using 
Automatic Speech Recognition (ASR), generate answers to user queries using 
a language model, and then convert those answers back to speech using 
Text-to-Speech (TTS).

Purpose
*******

* **Enable audio conversation with LLMs**: AudioAnA is to develop an innovative voice-to-text-to-LLM-to-text-to-voice conversational system that leverages advanced language models to facilitate seamless and natural communication between humans and machines. 

Key Implementation Details
**************************

User Interface:
  The interface that interactivates with users, gets inputs from users and 
  serves responses to users.
AudioQnA GateWay:
  The agent that maintains the connections between user-end and service-end, 
  forwards requests and responses to apropriate nodes.
AudioQnA MegaService:
  The central component that converts audio input to text using Automatic 
  Speech Recognition (ASR), generates answers to user queries using a language 
  model, and then converts those answers back to speech using Text-to-Speech (TTS).

How It Works
************

The AudioQnA example is implemented using the component-level microservices defined 
in `GenAI Components <https://github.com/opea-project/GenAIComps>`. The flow chart below 
shows the information flow between different microservices for this example.

.. mermaid::

   ---
   config:
     flowchart:
       nodeSpacing: 400
       rankSpacing: 100
       curve: linear
     themeVariables:
       fontSize: 50px
   ---
   flowchart LR
       %% Colors %%
       classDef blue fill:#ADD8E6,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
       classDef orange fill:#FBAA60,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
       classDef orchid fill:#C26DBC,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
       classDef invisible fill:transparent,stroke:transparent;
       style AudioQnA-MegaService stroke:#000000

       %% Subgraphs %%
       subgraph AudioQnA-MegaService["AudioQnA MegaService "]
           direction LR
           ASR([ASR MicroService]):::blue
           LLM([LLM MicroService]):::blue
           TTS([TTS MicroService]):::blue
       end
       subgraph UserInterface[" User Interface "]
           direction LR
           a([User Input Query]):::orchid
           UI([UI server<br>]):::orchid
       end

       WSP_SRV{{whisper service<br>}}
       SPC_SRV{{speecht5 service <br>}}
       LLM_gen{{LLM Service <br>}}
       GW([AudioQnA GateWay<br>]):::orange

       %% Questions interaction
       direction LR
       a[User Audio Query] --> UI
       UI --> GW
       GW <==> AudioQnA-MegaService
       ASR ==> LLM
       LLM ==> TTS

       %% Embedding service flow
       direction LR
       ASR <-.-> WSP_SRV
       LLM <-.-> LLM_gen
       TTS <-.-> SPC_SRV


This diagram illustrates the flow of information in the voice chatbot system, 
starting from the user input and going through the Audio2Text, response 
generations, and Text2Audio components, ultimately resulting in the bot's output.

The architecture follows a series of steps to process user queries and generate 
responses:

1. **Automatic Speech Recognition (ASR)**: ASR is used to accurately recognize and 
   transcribe human speech, which is crucial for LLMs. The ASR system receives audio 
   input, extracts features, maps features to sequences of phonemes and predict the 
   sequence of words corresponding to the phoneme sequence.
#. **Large Language Models (LLM)**: LLMs are used to generate text-based outputs 
   for specific text-based inputs, which are provided by ASR.
#. **Text-to-Speech (TTS)**: TTS is used to read text aloud in a way that sounds 
   natural, similar to human speech. The TTS system analyzes the input text, converts 
   the text into a standard form and converts normalized text into final speech.

Deployment
**********

Here are some deployment options depending on your hardware and environment.

Single Node
+++++++++++++++
.. toctree::
   :maxdepth: 1

   Xeon Scalable Processor <deploy/xeon>
   Gaudi <deploy/gaudi>