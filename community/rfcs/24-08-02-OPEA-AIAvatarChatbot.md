# 24-08-02-OPEA-AIAvatarChatbot

A RAG-Powered Human-Like AI Avatar Audio Chatbot integrated with OPEA AudioQnA
<!-- The short description of the feature you want to contribute -->

## Author
<!-- List all contributors of this RFC. -->
[ctao456](https://github.com/ctao456), [alexsin368](https://github.com/alexsin368), [YuningQiu](https://github.com/YuningQiu), [louie-tsai](https://github.com/louie-tsai)

## Status
<!-- Change the PR status to Under Review | Rejected | Accepted. -->
v0.1 - ASMO Team sharing on Fri 6/28/2024  
[GenAIComps pr #400](https://github.com/opea-project/GenAIComps/pull/400) (Under Review)  
[GenAIExamples pr #523](https://github.com/opea-project/GenAIExamples/pull/523) (Under Review)

## Objective
<!-- List what problem will this solve? What are the goals and non-goals of this RFC? -->
* "Digital humans will resolutionize industry". Given breakthroughs in LLMs and neural graphics, there emerged a surge in demand for human-computer interaction and conversational AI applications. To meet this demand, we need intent-driven computing where interacting with computers is as natural as interacting with humans. Yet all existing OPEA applications (ChatQnA, AudioQnA, SearchQnA, etc.) are text-based and lack interactive visual elements.

* Also worthnoting, the majority of existing OPEA applications lack multimodal features, i.e., they do not process both audio and visual inputs. Whereas enterprises are increasingly looking for multimodal AI solutions that can process both audio and visual inputs, to build lip-synchronized and face-animated chatbot solutions that are more engaging and human-like.

* Due to above reasons, we're hereby introducing a new microservice, animation, that generates animated avatars from audio and image/video inputs; and a new megaservice, AvatarChatbot, that integrates the animation microservice with the existing AudioQnA service to build a human-like AI audio chatbot.

<!--<p align="left">
  <img src="assets/avatar4.png" alt="Image 1" width="130"/>
  <img src="assets/avatar1.jpg" alt="Image 2" width="130"/>
  <img src="assets/avatar2.jpg" alt="Image 3" width="130"/>
  <img src="assets/avatar3.png" alt="Image 4" width="130"/> -->
  <!-- <img src="assets/avatar5.png" alt="Image 5" width="100"/> -->
  <!-- <img src="assets/avatar6.png" alt="Image 6" width="130"/>
</p> -->

![avatars chatbot](assets/avatars-chatbot.png)

The chatbot will:
* Be able to understand and respond to user text and audio queries, with a backend LLM model
* Synchronize audio response chunks with image/video frames, to generate a high-quality video of the avatar speaking in real-time
* Present the animated avatar response to the user in a user-friendly UI
* Use multimodal retrieval-augmented generation (RAG) to generate more accurate, in-domain responses, in v0.2

New microservices include:
* animation 

New megaservices include:
* AvatarChatbot

## Motivation
<!-- List why this problem is valuable to solve? Whether some related work exists? -->
* Enterprises in medical, finance, education, entertainment, etc. industries are increasingly adopting AI chatbots to improve customer service and user experience. Yet existing OPEA applications (ChatQnA, AudioQnA, SearchQnA, etc.) are text-based and lack interactive visual elements.
* Enterprises look for multimodal AI solutions that can process both audio and visual inputs, to build lip-synchronized and face-animated chatbots that are more engaging and human-like.
* This RFC aims to fill these gaps by introducing a new microservice, animation, that can be integrated seamlessly with existing micro- and mega-services in OPEA, to enhance the platform's capabilities in multimodal AI, human-computer interaction, and digital human graphics.

Overall, this project adds to the OPEA platform a new microservice block that animates the chatbot appearance, and integrates it with the existing chatbot pipelines such as [ChatQnA](https://github.com/opea-project/GenAIExamples/tree/2e312f44edbcbf89bf00bc21d9e9c847405ecae8/ChatQnA), [AudioQnA](https://github.com/opea-project/GenAIExamples/tree/2e312f44edbcbf89bf00bc21d9e9c847405ecae8/AudioQnA), [SearchQnA](https://github.com/opea-project/GenAIExamples/tree/2e312f44edbcbf89bf00bc21d9e9c847405ecae8/SearchQnA), etc., to build new chatbot megaservices that can interact with users in a more human-like way.

Related works include [Nvidia Audio2Face](https://docs.nvidia.com/ace/latest/modules/a2f-docs/index.html), [Lenovo Deepbrain AI Avatar](https://www.deepbrain.io/ai-avatars), [BitHuman](https://www.bithuman.io/), etc.

## Design Proposal
<!-- This is the heart of the document, used to elaborate the design philosophy and detail proposal. -->

### Avatar Chatbot design
<!-- Removed PPT slides -->

![avatar chatbot design](assets/design.png)

Currently, the RAG feature using the `embedding` and `dataprep` microservices is missing in the above design, including uploading relevant documents/weblinks, storing them in the database, and retrieving them for the LLM model. These features will be added in v0.2.  

Flowchart: AvatarChatbot Megaservice  
<!-- Insert Mermaid flowchart here -->
```mermaid
%%{ init : { "theme" : "base", "flowchart" : { "curve" : "stepBefore" }}}%%
flowchart TB
    style Megaservice stroke:#000000
    subgraph AvatarChatbot
        direction LR
        A[User] --> |Input query| B[AvatarChatbot Gateway]
        B --> |Invoke| Megaservice
        subgraph Megaservice["AvatarChatbot Megaservice"]
            direction LR
            subgraph AudioQnA["AudioQnA"]
                direction LR
                C([ASR<br>3001])
                E([LLM<br>3007])
                G([TTS<br>3002])
                C ==> E ==> G
            end
            subgraph AvatarAnimation["Avatar Animation"]
                direction LR
                I([Animation<br>3008])
            end
            G ==> I
        end
    end
    subgraph Legend
        direction LR
        L([Microservice]) 
        N[Gateway]
    end
```

The AvatarChatbot megaservice is a new service that integrates the existing AudioQnA service with the new animation microservice. The AudioQnA service is a pipeline that takes user audio input, converts it to text, generates an LLM response, and converts the response to audio output. The animation microservice is a new service that takes the audio response from the AudioQnA service, generates an animated avatar response, and sends it back to the user. The AvatarChatbot Gateway invokes the AvatarChatbot backend megaservice to generate the response.

#### animation microservice
The animation microservice is a new service that generates animated avatar videos from audio and image/video inputs. The animation microservice takes the audio response from the AudioQnA service, synchronizes the audio response mel-spectrogram chunks with image/video frames, and generates a high-quality video of the avatar speaking in real-time. The animation microservice currently uses the [Wav2Lip](https://github.com/Rudrabha/Wav2Lip) model for lip synchronization and [GFPGAN](https://github.com/TencentARC/GFPGAN) model for face restoration.  

User can build their own Docker image with `Dockerfile_hpu` and create a Docker container on Gaudi2 instance to run the animation microservice. They can then validate the service by sending a POST request to the server API, while providing audio and image/video inputs. The animation microservice will generate an animated avatar video response and save it to the specified output path.

Support for alternative SoTA models such as [SadTalker](https://github.com/OpenTalker/SadTalker) and [LivePortrait](https://github.com/KwaiVGI/LivePortrait) are in progress.

#### AvatarChatbot megaservice
The AvatarChatbot megaservice is a new service that integrates the existing microservices that comprise AudioQnA service with the new animation microservice. The AudioQnA service is a pipeline that takes user audio input, converts it to text, generates an LLM response, and converts the response to audio output. The animation microservice is a new service that takes the audio response from the AudioQnA service, generates an animated avatar response, and sends it back to the user. The megaflow is as follows:  
asr -> llm -> tts -> animation

```mermaid
---
config:
  flowchart:
    nodeSpacing: 100
    rankSpacing: 100
    curve: linear
  themeVariables:
    fontSize: 42px
---
flowchart LR
    %% Colors %%
    classDef blue fill:#ADD8E6,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
    classDef thistle fill:#D8BFD8,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
    classDef orange fill:#FBAA60,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
    classDef orchid fill:#C26DBC,stroke:#ADD8E6,stroke-width:2px,fill-opacity:0.5
    classDef invisible fill:transparent,stroke:transparent;
    style AvatarChatbot-Megaservice stroke:#000000

    %% Subgraphs %%    
    subgraph AvatarChatbot-Megaservice["AvatarChatbot Megaservice"]
        direction LR
        ASR([ASR<br>3001]):::blue
        LLM([LLM 'text-generation'<br>3007]):::blue
        TTS([TTS<br>3002]):::blue
        animation([Animation<br>3008]):::blue
    end
    subgraph UserInterface["User Interface"]
        direction LR
        invis1[ ]:::invisible
        USER1([User Audio Query]):::orchid
        USER2([User Image/Video Query]):::orchid
        UI([UI server<br>]):::orchid
    end
    subgraph ChatQnA GateWay
        direction LR
        invis2[ ]:::invisible
        GW([AvatarChatbot GateWay<br>]):::orange
    end
    subgraph  
        direction LR
        X([OPEA Microservice]):::blue
        Y{{Open Source Service}}:::thistle
        Z([OPEA Gateway]):::orange
        Z1([UI]):::orchid
    end

    %% Services %%    
    WHISPER{{Whisper service<br>7066}}:::thistle
    TGI{{LLM service<br>3006}}:::thistle
    T5{{Speecht5 service<br>7055}}:::thistle
    WAV2LIP{{Wav2Lip service<br>3003}}:::thistle

    %% Connections %%
    direction LR
    USER1 -->|1| UI
    UI -->|2| GW
    GW <==>|3| AvatarChatbot-Megaservice
    ASR ==>|4| LLM ==>|5| TTS ==>|6| animation

    direction TB
    ASR <-.->|3'| WHISPER
    LLM <-.->|4'| TGI
    TTS <-.->|5'| T5
    animation <-.->|6'| WAV2LIP

    USER2 -->|1| UI
    UI <-.->|6'| WAV2LIP
```


#### Frontend UI
The frontend UI is Gradio. User is prompted to upload either an image or a video as the avatar source. The user also asks his question verbally through the microphone by clicking on the "record" button. The AvatarChatbot backend processes the audio input and generates the response in the form of an animated avatar answering in its unique voice. The response is displayed on Gradio UI. User will be able to see the animated avatar speaking the response in real-time, and can interact with the avatar by asking more questions.

<!-- <div style="display: flex; justify-content: space-between;">
  <img src="assets/ui_latest_1.png" alt="alt text" style="width: 33%;"/>
  <img src="assets/ui_latest_2.png" alt="alt text" style="width: 33%;"/>
  <img src="assets/ui_latest_3.png" alt="alt text" style="width: 33%;"/>
</div> -->

![avatars ui](assets/avatars-ui.png)

### Real-time demo
AI Avatar Chatbot Demo on Intel® Gaudi® 2, image input (top) and video input (down)
<!-- <div style="display: flex; justify-content: space-between;">
  <video src="assets/demo_latest_image.mpg" controls style="width: 49%;"></video>
  <video src="assets/demo_latest_video.mpg" controls style="width: 49%;"></video>
</div> -->
![AI Avatar Chatbot Demo on Intel® Gaudi® 2, image input](assets/image_wav2lipgfpgan_cut.gif)


![AI Avatar Chatbot Demo on Intel® Gaudi® 2, video input](assets/video_wav2lipgfpgan_cut.gif)

## Compatibility
<!-- List possible incompatible interface or workflow changes if exists. -->
The new AvatarChatbot megaservice and animation microservice are compatible with the existing OPEA GenAIExamples and GenAIComps repos. They are deployable on Intel® Xeon® and Intel® Gaudi® hardware.

## Miscs
<!-- List other information user and developer may care about, such as:
- Performance Impact, such as speed, memory, accuracy.
- Engineering Impact, such as binary size, startup time, build time, test times.
- Security Impact, such as code vulnerability.
- TODO List or staging plan.  -->
End-to-End Inference Time for AvatarChatbot Megaservice (asr -> llm -> tts -> animation): 

On SPR:  
~30 seconds for AudioQnA on SPR,  
~40-200 seconds for AvatarAnimation on SPR

On Gaudi 2:  
~5 seconds for AudioQnA on Gaudi, 
~10-50 seconds for AvatarAnimation on Gaudi, depending on:  
1) Whether the input is an image or a multi-frame, fixed-fps video
1) LipSync Animation DL model used: Wav2Lip_only or Wav2Lip+GFPGAN or SadTalker  
2) Resolution and FPS rate of the resulting mp4 video

All latency reportings are as of 8/2/2024.
