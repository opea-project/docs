.. _ChatQnA_Guide:

ChatQnA
######################

.. note:: 이 가이드는 초기 개발 단계에 있으며, 플레이스홀더 콘텐츠가 있는 진행 중인 작업입니다.

개요
********

채팅봇은 대규모 언어 모델(LLM)의 강력한 채팅 및
추론 기능을 활용하는 널리 채택된 사용 사례입니다. ChatQnA 예제는
개발자가 GenAI 공간에서 작업을 시작할 수 있는 시작점을 제공합니다.
GenAI 애플리케이션의 "hello world"로 간주하고 내부 및 외부적으로 광범위한 기업 수직 솔루션에 활용할 수 있습니다.

목적
*******

ChatQnA 예제는 검색 증강 생성(RAG) 아키텍처를 사용하는데,
이 아키텍처는 빠르게 채팅봇 개발의 산업 표준이 되고 있습니다. 이는 지식 기반(벡터 저장소를 통해)과 생성 모델의 이점을 결합하여 환각을 줄이고 최신 정보를 유지하며 도메인별 지식을 활용합니다.

RAG는 외부 소스에서 관련 정보를 동적으로 가져와 지식 격차를 메우고 생성된 응답이 사실적이고 최신 상태를 유지하도록 합니다.
이 아키텍처의 핵심은 벡터 데이터베이스로, 이는 정보의 효율적이고 의미론적 검색을 가능하게 하는 데 도움이 됩니다. 이러한 데이터베이스는 데이터를 벡터로 저장하여 RAG가 의미론적 유사성에 따라 가장 관련성 있는 문서나 데이터 포인트에 빠르게 액세스할 수 있도록 합니다.

RAG 아키텍처의 핵심은 사용자 질의에 대한 응답을 생성하는 생성 모델을 사용하는 것입니다. 생성 모델은 사용자 정의 및 관련 텍스트 데이터의 방대한 코퍼스에서 학습되었으며 인간과 유사한 응답을 생성할 수 있습니다. 개발자는 생성 모델이나 벡터 데이터베이스를 자체 사용자 정의 모델이나 데이터베이스로 쉽게 바꿀 수 있습니다. 이를 통해
개발자는 특정 사용 사례와 요구 사항에 맞게 조정된 챗봇을 빌드할 수 있습니다. RAG는 생성 모델을 벡터 데이터베이스와 결합하여
사용자의
질문에 맞는 정확하고 상황에 맞는 응답을 제공할 수 있습니다.

ChatQnA 예제는 RAG 아키텍처의 간단하면서도 강력한 데모로 설계되었습니다.
사용자에게 정확하고 최신 정보를 제공할 수 있는 챗봇을 빌드하려는 개발자에게 좋은 시작점입니다.

여러 GenAI 애플리케이션에서 개별 서비스를 공유하기 쉽게 하려면 GenAI Microservices Connector(GMC)를 사용하여 애플리케이션을 배포합니다. 서비스 공유 외에도 GenAI 파이프라인에서 순차적, 병렬적, 대체적 단계를 지정하는 것도 지원합니다. 이를 통해 GenAI 파이프라인의 모든 단계에서 사용되는 모델 간의 동적 전환을 지원합니다. 예를 들어 ChatQnA 파이프라인 내에서 GMC를 사용하면 임베더, 재순위 지정자 및/또는 LLM에서 사용되는 모델을 전환할 수 있습니다.
업스트림 바닐라 쿠버네티스 또는 Red Hat OpenShift 컨테이너
플랫폼(RHOCP)은 GMC와 함께 사용하거나 사용하지 않고 사용할 수 있으며, GMC와 함께 사용하면 추가 기능이 제공됩니다.

ChatQnA는 Xeon 확장 가능 프로세서, Gaudi 서버, NVIDIA GPU, 심지어 AI PC와 같은 하드웨어를 사용하여 온프레미스 또는 클라우드 환경에서 단일 노드 배포를 포함한 여러 배포 옵션을 제공합니다. 또한 GenAI 관리 콘솔(GMC)이 있거나 없는 Kubernetes 배포와 RHOCP를 사용하는 클라우드 네이티브 배포도 지원합니다.

주요 구현 세부 정보
****************************

임베딩:
사용자 쿼리를 임베딩이라고 하는 수치 표현으로 변환하는 프로세스입니다.
벡터 데이터베이스:
벡터 데이터베이스를 사용하여 관련 데이터 포인트를 저장하고 검색합니다.
RAG 아키텍처:
RAG 아키텍처를 사용하여 지식 기반과 생성 모델을 결합하여 관련성 있고 최신 쿼리 응답이 있는 챗봇을 개발합니다.
대규모 언어 모델(LLM):
응답을 생성하기 위한 LLM의 교육 및 활용.
배포 옵션:
ChatQnA 예제에 대한 프로덕션 준비 배포 옵션, 단일 노드 배포 및 Kubernetes 배포 포함.

작동 방식
************

ChatQnA 예제는 챗봇 시스템에서 기본적인 정보 흐름을 따르며
사용자 입력에서 시작하여 검색, 재순위 지정 및 생성 구성 요소를 거쳐
궁극적으로 봇의 출력으로 이어집니다.

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_architecture.png
:alt: ChatQnA 아키텍처 다이어그램

이 다이어그램은 챗봇 시스템에서 정보의 흐름을 보여줍니다.
사용자 입력에서 시작하여 검색, 분석 및 생성 구성 요소를 거쳐
궁극적으로 봇의 출력으로 이어집니다.

아키텍처는 일련의 단계를 따라 사용자 쿼리를 처리하고 응답을 생성합니다.

1. **임베딩**: 사용자 쿼리는 먼저 임베딩이라는 숫자 표현으로 변환됩니다.
이 임베딩은 쿼리의 의미적 의미를 포착하고 다른 임베딩과 효율적으로 비교할 수 있도록 합니다.
#. **벡터 데이터베이스**: 임베딩은 벡터 데이터베이스를 검색하는 데 사용됩니다.
벡터 데이터베이스는 관련 데이터 포인트를 벡터로 저장합니다. 벡터 데이터베이스는
쿼리 임베딩과 저장된 벡터 간의 유사성을 기반으로 정보를 효율적이고 의미적으로 검색할 수 있도록 합니다.
#. **재순위 매기기**: 모델을 사용하여 검색된 데이터의 탁월성에 따라 순위를 매깁니다.
벡터 데이터베이스는 쿼리 임베딩을 기반으로 가장 관련성 있는 데이터 포인트를 검색합니다.
이러한 데이터 포인트에는 문서,
기사 또는 정확한
응답을 생성하는 데 도움이 되는 기타 관련 정보가 포함될 수 있습니다.
#. **LLM**: 검색된 데이터 포인트는 추가 처리를 위해 대규모 언어 모델(LLM)로 전달됩니다. LLM은 대규모 텍스트 데이터 코퍼스에서
학습된 강력한 생성 모델입니다. 입력 데이터를 기반으로 인간과 유사한
응답을 생성할 수 있습니다.
#. **응답 생성**: LLM은 입력 데이터와 사용자 쿼리를 기반으로 응답을 생성합니다. 이 응답은 챗봇의 답변으로 사용자에게 반환됩니다.

예상 출력
===============

TBD

검증 매트릭스 및 전제 조건
===================================

참조 :doc:`/GenAIExamples/supported_examples`

아키텍처
************

ChatQnA 아키텍처는 아래와 같습니다.

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_flow_chart.png
:alt: ChatQnA 아키텍처 다이어그램

마이크로서비스 개요 및 다이어그램
================================

OPEA의 GenAI 애플리케이션 또는 파이프라인은 일반적으로 게이트웨이를 통해 액세스되는 메가서비스를 만드는 마이크로서비스 모음으로 구성됩니다. 마이크로서비스는 특정 기능 또는 작업을 수행하도록 설계된 구성 요소입니다. 마이크로서비스는 기본 서비스를 제공하는 빌딩 블록입니다. 마이크로서비스는 시스템에서 모듈성, 유연성, 확장성을 촉진합니다. 메가서비스는 하나 이상의 마이크로서비스로 구성된 상위 수준의 아키텍처 구성 요소로, 엔드투엔드 애플리케이션을 조립할 수 있는 기능을 제공합니다.
게이트웨이는 사용자가 액세스할 수 있는 인터페이스 역할을 합니다. 게이트웨이는 들어오는 요청을 메가서비스 아키텍처 내의 적절한 마이크로서비스로 라우팅합니다. 자세한 내용은 `GenAI 구성 요소 <https://github.com/opea-project/GenAIComps>`_를 참조하세요.

.. mermaid::

   graph LR
    subgraph ChatQnA-MegaService["ChatQnA-MegaService"]
        direction LR
        EM([Embedding 'LangChain TEI' <br>6000])
        RET([Retrieval 'LangChain Redis'<br>7000])
        RER([Rerank 'TEI'<br>8000])
       LLM([LLM 'text-generation TGI'<br>9000])
    end

    direction TB
    TEI_EM{{TEI embedding service<br>8090}}
    VDB{{Vector DB<br>8001}}
    %% Vector DB interaction
    TEI_EM -.->|d|VDB

    DP([OPEA Data Preparation<br>6007])
    LLM_gen{{TGI/vLLM/ollama Service}}

    direction TB
    RER([OPEA Reranking<br>8000])
    TEI_RER{{TEI Reranking service<br>8808}}

    subgraph User Interface
        direction TB
        a[User Input Query]
        Ingest[Ingest data]
        UI[UI server<br>Port: 5173]
    end

    subgraph ChatQnA GateWay
        direction LR
        GW[ChatQnA GateWay<br>Port: 8888]
    end

    %% Data Preparation flow
    %% Ingest data flow
    direction LR
    Ingest[Ingest data] -->|a| UI
    UI -->|b| DP
    DP -.->|c| TEI_EM

    %% Questions interaction
    direction LR
    a[User Input Query] -->|1| UI
    UI -->|2| GW
    GW ==>|3| ChatQnA-MegaService
    EM ==>|4| RET
    RET ==>|5| RER
    RER ==>|6| LLM


    %% Embedding service flow
    direction TB
    EM -.->|3'| TEI_EM
    RET -.->|4'| TEI_EM
    RER -.->|5'| TEI_RER
    LLM -.->|6'| LLM_gen

    subgraph Legend
        X([Microservice])
        Y{{Service from industry peers}}
        Z[Gateway]
    end


배포
************

다음은 하드웨어 및 환경에 따라 몇 가지 배포 옵션입니다.
여기에는 단일 노드와 오케스트레이션된 다중 노드 구성이 모두 포함됩니다.
요구 사항에 가장 적합한 것을 선택하세요.

단일 노드
**********

.. toctree::
   :maxdepth: 1

   Xeon Scalable Processor <deploy/xeon>
   Gaudi AI Accelerator <deploy/gaudi>
   Nvidia GPU <deploy/nvidia>
   AI PC <deploy/aipc>

----

Kubernetes
**********

.. toctree::
   :maxdepth: 1

   Getting Started <deploy/k8s_getting_started>
   Kubernetes Deployment with Helm on Xeon <deploy/k8s_helm>

클라우드 네이티브
************

* Red Hat OpenShift Container Platform(RHOCP)

문제 해결
****************

1. 브라우저 인터페이스 https 링크 실패

질문: 예를 들어, IBM Cloud에서 ChatQnA 예제를 시작하고 UI 인터페이스에 액세스하려고 합니다. 기본적으로 :5173을 입력하면 https://:5173으로 변환됩니다. Chrome에서 다음과 같은 경고 메시지가 표시됩니다. xx.xx.xx.xx는 보안 연결을 지원하지 않습니다.

답변: 기본적으로 브라우저가 xx.xx.xx.xx:5173을 https://xx.xx.xx.xx:5173으로 변환하기 때문입니다. 그러나 보안 요구 사항을 충족하려면 사용자가 인증서를 배포하여 일부 클라우드 환경에서 HTTPS 지원을 활성화해야 합니다. OPEA는 기본적으로 HTTP 서비스를 제공하지만 HTTPS도 지원합니다. HTTPS를 활성화하려면 MicroService 클래스에서 인증서 파일 경로를 지정할 수 있습니다. 자세한 내용은 `소스 코드 <https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/micro_service.py#L33>`_를 참조하세요.

2. 다른 문제는 `문서 <https://opea-project.github.io/latest/GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi/how_to_validate_service.html>`_를 확인하세요.

모니터링
**********

이제 ChatQnA 예제를 배포했으므로 ChatQnA 파이프라인에서 마이크로서비스의 성능을 모니터링하는 방법에 대해 알아보겠습니다.

마이크로서비스의 성능을 모니터링하는 것은 생성 AI 시스템의 원활한 작동을 보장하는 데 중요합니다. 지연 시간 및 처리량과 같은 메트릭을 모니터링하면 병목 현상을 식별하고 이상을 감지하며 개별 마이크로서비스의 성능을 최적화할 수 있습니다. 이를 통해 모든 문제를 사전에 해결하고 ChatQnA 파이프라인이 효율적으로 실행되도록 할 수 있습니다.

이 문서는 다양한 마이크로서비스의 대기 시간, 처리량 및 기타 메트릭을 실시간으로 모니터링하는 방법을 이해하는 데 도움이 됩니다. **Prometheus**와 **Grafana**(둘 다 오픈소스 툴킷)를 사용하여 메트릭을 수집하고 대시보드에서 시각화합니다.

Prometheus 서버 설정
=============================

Prometheus는 실시간 메트릭을 기록하는 데 사용되는 도구이며, 마이크로서비스를 모니터링하고 메트릭을 기반으로 경고하도록 특별히 설계되었습니다.

각 마이크로서비스를 실행하는 포트의 `/metrics` 엔드포인트는 Prometheus 형식으로 메트릭을 노출합니다. Prometheus 서버는 이러한 메트릭을 스크래핑하여 시계열 데이터베이스에 저장합니다. 예를 들어, Text Generation Interface(TGI) 서비스의 메트릭은 다음에서 사용할 수 있습니다.

.. code-block:: bash

   http://${host_ip}:9009/metrics

Prometheus 서버 설정:

1. Prometheus 다운로드:
공식 사이트에서 Prometheus v2.52.0을 다운로드하고 파일을 추출합니다.

.. code-block:: bash

   wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
   tar -xvzf prometheus-2.52.0.linux-amd64.tar.gz

2. Prometheus 구성:
디렉토리를 Prometheus 폴더로 변경:

.. code-block:: bash

   cd prometheus-2.52.0.linux-amd64

`prometheus.yml` 파일을 편집합니다.

.. code-block:: bash

   vim prometheus.yml

``job_name``을 모니터링하려는 마이크로서비스의 이름으로 변경합니다. 또한 ``targets``를 해당 마이크로서비스의 작업 대상 엔드포인트로 변경합니다. 서비스가 실행 중이고 포트가 열려 있으며 ``/metrics`` 엔드포인트에서 Prometheus 규칙을 따르는 메트릭을 노출하는지 확인합니다.

다음은 TGI 마이크로서비스에서 Prometheus로 메트릭 데이터를 내보내는 예입니다.

.. code-block:: yaml

   # A scrape configuration containing exactly one endpoint to scrape:
   # Here it's Prometheus itself.
   scrape_configs:
     # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
     - job_name: "tgi"

       # metrics_path defaults to '/metrics'
       # scheme defaults to 'http'.

       static_configs:
         - targets: ["localhost:9009"]

다음은 TGI 마이크로서비스(Kubernetes 클러스터 내부)에서 Prometheus로 메트릭 데이터를 내보내는 또 다른 예입니다.

.. code-block:: yaml

   scrape_configs:
     - job_name: "tgi"

       static_configs:
         - targets: ["llm-dependency-svc.default.svc.cluster.local:9009"]

3. Prometheus 서버를 실행합니다.
프로세스를 중단하지 않고 Prometheus 서버를 실행합니다.
```bash
nohup ./prometheus --config.file=./prometheus.yml &
```

4. Prometheus UI에 액세스
다음 URL에서 Prometheus UI에 액세스하세요.

.. code-block:: bash

   http://localhost:9090/targets?search=

>참고: Prometheus를 시작하기 전에 지정된 포트(기본값은 9090)에서 다른 프로세스가 실행되고 있지 않은지 확인하세요. 그렇지 않으면 Prometheus가 메트릭을 스크래핑할 수 없습니다.

Prometheus UI에서 대상의 상태와 스크래핑되는 메트릭을 볼 수 있습니다. 검색 창에 입력하여 메트릭 변수를 검색할 수 있습니다.

TGI 메트릭은 다음에서 액세스할 수 있습니다.

.. code-block:: bash

   http://${host_ip}:9009/metrics

Grafana 대시보드 설정
=============================

Grafana는 메트릭을 시각화하고 대시보드를 만드는 데 사용되는 도구입니다. Prometheus에서 수집한 메트릭을 표시하는 사용자 지정 대시보드를 만드는 데 사용할 수 있습니다.

Grafana 대시보드를 설정하려면 다음 단계를 따르세요.

1. Grafana 다운로드:
공식 사이트에서 Grafana v8.0.6을 다운로드하고 파일을 추출합니다.

.. code-block:: bash

   wget https://dl.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz
   tar -zxvf grafana-11.0.0.linux-amd64.tar.gz

추가 지침은 전체 `Grafana 설치 지침 <https://grafana.com/docs/grafana/latest/setup-grafana/installation/>`_을 참조하세요.

2. Grafana 서버를 실행합니다.
디렉토리를 Grafana 폴더로 변경합니다.

.. code-block:: bash

   cd grafana-11.0.0

프로세스를 중단하지 않고 Grafana 서버를 실행합니다.

.. code-block:: bash

   nohup ./bin/grafana-server &

3. Grafana 대시보드 UI에 액세스:
브라우저에서 다음 URL에서 Grafana 대시보드 UI에 액세스하세요.

.. code-block:: bash

   http://localhost:3000

>참고: Grafana를 시작하기 전에 포트 3000에서 다른 프로세스가 실행되고 있지 않은지 확인하세요.

기본 자격 증명을 사용하여 Grafana에 로그인하세요.

.. code-block::

   username: admin
   password: admin

4. Prometheus를 데이터 소스로 추가:
Grafana가 데이터를 스크래핑할 데이터 소스를 구성해야 합니다. "데이터 소스" 버튼을 클릭하고 Prometheus를 선택한 다음 Prometheus URL ``http://localhost:9090``을 지정합니다.

그런 다음 대시보드 구성을 위한 JSON 파일을 업로드해야 합니다. Grafana UI의 ``홈 > 대시보드 > 대시보드 가져오기``에서 업로드할 수 있습니다. 샘플 JSON 파일은 여기에서 지원됩니다: `tgi_grafana.json <https://github.com/huggingface/text-generation-inference/blob/main/assets/tgi_grafana.json>`_

5. 대시보드 보기:
마지막으로 Grafana UI에서 대시보드를 열면 메트릭 데이터를 표시하는 다양한 패널이 표시됩니다.

TGI 마이크로서비스를 예로 들면 다음과 같은 지표를 볼 수 있습니다.
* 첫 번째 토큰까지의 시간
* 토큰당 디코딩 지연 시간
* 처리량(초당 생성된 토큰)
* 프롬프트당 토큰 수
* 요청당 생성된 토큰 수

마이크로서비스에 들어오는 요청, 토큰당 응답 시간 등을 실시간으로 모니터링할 수도 있습니다.

요약 및 다음 단계
=======================

TBD