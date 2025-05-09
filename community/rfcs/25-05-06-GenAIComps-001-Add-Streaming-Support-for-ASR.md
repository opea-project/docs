# Add Streaming Automatic Speech Recognition (ASR) support in GenAIComps

## Author(s)

[Ruoyu Ying](https://github.com/Ruoyu-y)

## Status

`Under Review`

## Objective

This RFC proposes to enhance the current ASR service to support streaming ASR. The goal is make our speech-to-text service compatible for latency-sensitive scenarios.

## Motivation

Currently our GenAIComps supports speech-to-text ASR services by accepting audio files and returning a full transcription once ready. However, file-based offline transcription, while useful for post-processing, introduces latency and cannot meet the low-latency, high-reliability demands of time-sensitive edge use cases. Realtime transcription or streaming ASR is crucial as it enables immediate response, it requires consuming streaming input from devices and streaming output.

## Use-cases

**Audio-based live streaming agent**

While collaborating with ByteDance on their use case of an audio-based live streaming agent, streaming input from the streamer needs to be transcribed into text in real time and trigger one or more actions based on the text content. To ensure a prompt response, streaming/delta input handling is required versus waiting for the full audio to finish.

## Design Proposal

New interfaces will be introduced to support streaming ASR, designed for compatibility by following OpenAI’s Realtime API at https://platform.openai.com/docs/guides/realtime-transcription.

Currently, several endpoints are introduced following OpenAI's standard:

### Endpoint to commit streaming audio data and get delta response

```
POST /v1/realtime/intent=transcription
```

This API append audio bytes to the input audio buffer. VAD is enabled by default, so that the ASR server will commit the audio buffer automatically and return the response.

**Request Body**:
```
class DeltaInputAudioData:
    audio:    str               # Base64-encoded audio bytes
    event_id: Optional[str]     # Optional client-generated ID used to identify this event.
    type:     str               # The event type
```

**Response**:
```
class LogProbObject(BaseModel):
    bytes: List               # The bytes that were used to generate the log probability.
    logprob: float            # The log probability of the token.
    token: str                # The token that was used to generate the log probability.

class RealtimeTranscriptionDeltaResponse:
    content_index: int                                  # The index of the content part in the item's content array.
    delta:         str                                  # The text delta
    event_id:      str                                  # The unique ID of the server event.
    item_id:       str                                  # The ID of the item.
    logprobs:      Optional[List[LogProbObject]] = None # The log probabilities of the transcription.
    type:          str                                  # The event type
```

### Endpoint to create transcription session

```
POST  /v1/realtime/transcription_sessions
```

This API creates an ephemeral API token for use in client-side applications with realtime transcriptions. It responds with a session object, plus a client_secret key which contains a usable ephemeral API token that can be used to authenticate clients for the Realtime API.


**Request Body**:
```
class NoiseReductionObj:
    type Optional[str]  # Type of noise reduction. Not supported for now.

class TranscriptionConfig:
    language Optional[str]  # The language of the input audio.
    model    Optional[str]  # The model to use for transcription, current options are the Whisper families.
    prompt   Optional[str]  # An optional text to guide the model's style or continue a previous audio segment. Not supported for now.

class DetectionConfig:
    eagerness           Optional[str]="auto"        # Used only for semantic_vad mode. Not supported for now.
    prefix_padding_ms   Optional[int]               # Used only for server_vad mode. Amount of audio to include before the VAD detected speech (in milliseconds). 
    silence_duration_ms Optional[int]               # Used only for server_vad mode. Duration of silence to detect speech stop (in milliseconds).
    threshold           Optional[float]             # Used only for server_vad mode. Activation threshold for VAD (0.0 to 1.0). Not supported for now.
    type                Optional[str]="server_vad"  # Type of turn detection.
    
class TranscriptionSessionRequest:
    include Optional[List] = None                                   # The set of items to include in the transcription. Current available items are: null.
    input_audio_format Optional[str] = "pcm16"                      # The format of input audio. Options is pcm16 for now.
    input_audio_noise_reduction Optional[NoiseReductionObj] = None  # Configuration for input audio noise reduction.
    input_audio_transcription Optional[TranscriptionConfig]         # Configuration for input audio transcription. See TranscriptionConfig above.
    modalities Optional[List[str]]                                  # The set of modalities the model can respond with. Currently 'text' only.
    turn_detection Optional[DetectionConfig]                        # Configuration for turn detection. See DetectionConfig above
```

**Response**:
```
class ClientSecretObj:
    expires_at int # Timestamp for when the token expires.
    value      str # Ephemeral key usable in client environments to authenticate connections to the Realtime API.

class DetectionConfigResp:
    prefix_padding_ms   int   # Amount of audio to include before the VAD detected speech (in milliseconds).
    silence_duration_ms int   # Duration of silence to detect speech stop (in milliseconds). 
    threshold           float # Activation threshold for VAD (0.0 to 1.0).
    type                str   # Type of turn detection.

class TranscriptionSessionResponse:
    client_secret               ClientSecretObj     # Ephemeral key returned by the API. Only present when the session is created on the server via REST API. 
    input_audio_format          str                 # The format of input audio.
    input_audio_transcription   TranscriptionConfig # Configuration of the transcription model. See the TranscriptionConfig above.
    modalities                  List                # The set of modalities the model can respond with.
    turn_detection              DetectConfigResp    # Configuration for turn detection.
```

### Implementation Proposal

The implementation of the streaming ASR will be cut into two phases. 

First, we will implement the endpoint to commit streaming audio data and get delta response. The streaming ASR endpoint will be implemented based on **websocket** in order to meet the need of streaming input. Then the service itself will handle the audio chunking work and send the chunked data to **Whisper** model for transcription. In phase 1, the model size, chunk size and audio format will be set through docker argument while starting the service. For VAD support, CPU based streaming ASR will leverage the `faster_whisper` library and the Intel XPU based streaming ASR will leverage the `webrtcvad` library.

Next, we would see if it is required to provide the transcription session for realtime transcription configuration. Configurations like input_audio_format, threshold, silence_duration can be set once creating the transcription session. Also client secret may get authenticated while using the `/v1/realtime/intent=transcription` endpoint.

## Known concerns

Here we leverage the transformers framework to implement the streaming ASR service on Whisper model. Nvidia also provides streaming ASR service based on the Conformer-CTC models which are distributed with NeMo. Although CTC models may outperform Whisper in some cases, they are tightly coupled with NVIDIA’s software and hardware stack. Therefore, we chose Whisper for our implementation to ensure broader compatibility and flexibility.

## Miscellaneous

