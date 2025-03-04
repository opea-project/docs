.. _ChatQnA_Guide:

ChatQnA
####################

.. note:: 本指南仍在早期开发阶段，内容尚未完善。

概述
********

聊天机器人是利用大型语言模型（LLMs）强大聊天和推理能力的广泛采用用例。ChatQnA 示例为开发人员在生成式人工智能（GenAI）领域开始工作提供了起点。可以将其视为 GenAI 应用程序的“你好，世界”，并可用于各种企业垂直领域的解决方案，包括内部和外部。

目标
*******

ChatQnA 示例使用检索增强生成（RAG）架构，这种架构正迅速成为聊天机器人开发的行业标准。它结合了知识库（通过向量存储）和生成模型的优点，从而降低幻觉现象，保持最新信息，并利用特定领域知识。

RAG 通过动态获取外部来源的相关信息来弥补知识鸿沟，确保生成的响应保持事实准确和最新。本架构的核心是向量数据库，它们在高效和语义检索信息方面起着重要作用。这些数据库将数据存储为向量，使 RAG 能够根据语义相似性快速访问最相关的文档或数据点。

RAG 架构的核心是使用生成模型，该模型负责生成对用户查询的响应。生成模型经过大规模定制和相关文本数据的训练，能够生成类似人类的响应。开发人员可以轻松替换生成模型或向量数据库，使用自己的自定义模型或数据库。这使得开发人员能够构建符合其特定用例和需求的聊天机器人。通过将生成模型与向量数据库结合，RAG 可以提供准确和上下文相关的响应，特定于用户的查询。

ChatQnA 示例旨在展示 RAG 架构的简单而强大的示范。它是希望构建能够为用户提供准确和最新信息的聊天机器人的开发人员的良好起点。

为了促进行业应用服务的跨多个 GenAI 应用程序的共享，使用 GenAI 微服务连接器 (GMC) 部署你的应用。除了服务共享，它还支持在 GenAI 管道中指定顺序、并行和替代步骤。通过这样做，它支持在任意 GenAI 管道阶段动态切换使用的模型。例如，在 ChatQnA 管道中，使用 GMC 可以切换在嵌入器、重新排序器和/或 LLM 中使用的模型。上游普通 Kubernetes 或红帽 OpenShift 容器平台 (RHOCP) 可以与或不与 GMC 一起使用，而与 GMC 一起使用会提供额外的功能。

ChatQnA提供几种部署选项，包括基于物理硬件（如 Xeon 可扩展处理器、Gaudi 服务器、NVIDIA GPU，甚至 AI PC）的单节点部署、在本地或云环境中进行的部署。它还支持使用或不使用 GenAI 管理控制台 (GMC) 的 Kubernetes 部署，以及使用 RHOCP 的云原生部署。

关键实现细节
**************************

嵌入：
  将用户查询转换为称为嵌入的数值表示的过程。
向量数据库：
  使用向量数据库存储和检索相关数据点。
RAG 架构：
  使用 RAG 架构将知识库和生成模型结合起来，以开发具有相关且最新查询响应的聊天机器人。
大型语言模型（LLMs）：
  训练和利用 LLM 生成响应。
部署选项：
  针对 ChatQnA 示例的生产就绪部署选项，包括单节点部署和 Kubernetes 部署。

工作原理
************

ChatQnA 示例遵循聊天机器人系统中的基本信息流，从用户输入开始，通过检索、重新排序和生成组件，最终生成机器人的输出。

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_architecture.png
   :alt: ChatQnA 架构图

   本图描述了聊天机器人系统中的信息流，从用户输入开始，经过检索、分析和生成组件，最终生成机器人的输出。

该架构遵循一系列步骤来处理用户查询并生成响应：

1. **嵌入**：用户查询首先被转换为称为嵌入的数值表示。该嵌入捕捉了查询的语义含义，并允许与其他嵌入的高效比较。
#. **向量数据库**：然后使用嵌入在向量数据库中搜索，存储相关数据点作为向量。向量数据库基于查询嵌入和存储向量之间的相似性，使信息的高效和语义检索成为可能。
#. **重新排序器**：使用模型对检索的数据进行重要性排序。向量数据库根据查询嵌入检索出最相关的数据点。这些数据点可以包括文档、文章或任何其他可以帮助生成准确响应的相关信息。
#. **LLM**：检索到的数据点随后传递给大型语言模型（LLM）进行进一步处理。LLM 是强大的生成模型，已经在大型文本数据语料库上训练。它们可以基于输入数据生成类似人类的响应。
#. **生成响应**：LLM 根据输入数据和用户查询生成响应。然后将该响应作为聊天机器人的答案返回给用户。

预期输出
===============

待定

验证标准和前提条件
===================================

见 :doc:`/GenAIExamples/supported_examples`

架构
************

下面展示了 ChatQnA 的架构：

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_flow_chart.png
   :alt: ChatQnA 架构图

微服务大纲和图示
================================

一个 GenAI 应用或 OPEA 中的管道通常由一组微服务组成，以创建一个巨型服务，通过网关访问。微服务是设计用于执行特定功能或任务的组件。微服务是构建模块，提供基本服务。微服务促进了系统的模块化、灵活性和可扩展性。巨型服务是一个更高级的架构构造，由一个或多个微服务组成，提供组装端到端应用程序的能力。网关作为用户访问的接口。网关将传入请求路由到巨型服务架构中的适当微服务。有关更多信息，请参见 `GenAI 组件 <https://github.com/opea-project/GenAIComps>`_。

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

    %% 数据准备流程
    %% 数据采集流程
    direction LR
    Ingest[Ingest data] -->|a| UI
    UI -->|b| DP
    DP -.->|c| TEI_EM

    %% 问题交互
    direction LR
    a[User Input Query] -->|1| UI
    UI -->|2| GW
    GW ==>|3| ChatQnA-MegaService
    EM ==>|4| RET
    RET ==>|5| RER
    RER ==>|6| LLM


    %% 嵌入服务流程
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

部署
**********

根据您的硬件和环境，以下是一些部署选项。这包括单节点和协作多节点配置。选择最符合您要求的选项。

单节点
***********

.. toctree::
   :maxdepth: 1

   Xeon 可扩展处理器 <deploy/xeon>
   Gaudi AI 加速器 <deploy/gaudi>
   Nvidia GPU <deploy/nvidia>
   AI PC <deploy/aipc>

----

Kubernetes
**********

.. toctree::
   :maxdepth: 1

   入门指南 <deploy/k8s_getting_started>
   在 Xeon 上使用 Helm 的 Kubernetes 部署 <deploy/k8s_helm>

云原生
************

* 红帽 OpenShift 容器平台 (RHOCP)

故障排除
***************

1. 浏览器界面 HTTPS 链接失败

   Q: 例如，在 IBM Cloud 中启动 ChatQnA 示例并尝试访问用户界面。默认情况下，输入 :5173 将解析为 https://:5173。Chrome 显示以下警告信息：xx.xx.xx.xx 不支持安全连接。

   A: 这是因为默认情况下，浏览器将 xx.xx.xx.xx:5173 解析为 https://xx.xx.xx.xx:5173。但为满足安全要求，用户需要部署证书以在某些云环境中启用 HTTPS 支持。OPEA 默认提供 HTTP 服务，但也支持 HTTPS。要启用 HTTPS，可以在微服务类中指定证书文件路径。有关更多详细信息，请参见 `源代码 <https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/micro_service.py#L33>`_。

2. 对于其他问题，请查看 `文档 <https://opea-project.github.io/latest/GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi/how_to_validate_service.html>`_。

监控
**********

现在你已经部署了 ChatQnA 示例，让我们来讨论对 ChatQnA 管道中微服务性能的监控。

监控微服务的性能对于确保生成式人工智能系统的顺利运行至关重要。通过监控延迟和吞吐量等指标，您可以识别瓶颈、检测异常并优化各个微服务的性能。这使我们能够主动解决任何问题，确保 ChatQnA 管道高效运行。

本文档将帮助您了解如何实时监控不同微服务的延迟、吞吐量和其他指标。您将使用 **Prometheus** 和 **Grafana**，这两种开源工具集，用于收集指标并在仪表板中可视化它们。

设置 Prometheus 服务器
============================

Prometheus 是一个用于记录实时指标的工具，专门用于监控微服务并根据其指标进行警报。

每个微服务在运行的端口上的 `/metrics` 端点以 Prometheus 格式公开指标。Prometheus 服务器抓取这些指标并将它们存储在其时间序列数据库中。例如，文本生成接口 (TGI) 服务的指标可通过以下地址获得：

.. code-block:: bash

   http://${host_ip}:9009/metrics

设置 Prometheus 服务器：

1. 下载 Prometheus：
   从官方网站下载 Prometheus v2.52.0，并提取文件：

.. code-block:: bash

   wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
   tar -xvzf prometheus-2.52.0.linux-amd64.tar.gz

2. 配置 Prometheus：
   将目录更改为 Prometheus 文件夹：

.. code-block:: bash

   cd prometheus-2.52.0.linux-amd64

编辑 `prometheus.yml` 文件：

.. code-block:: bash

   vim prometheus.yml

将 ``job_name`` 更改为要监控的微服务的名称。同时将 ``targets`` 更改为该微服务的作业目标端点。确保服务正在运行且端口已打开，并且它在 ``/metrics`` 端点上公开遵循 Prometheus 规范的指标。

以下是从 TGI 微服务导出指标数据到 Prometheus 的示例：

.. code-block:: yaml

   # 一项抓取配置，包含一个要抓取的端点：
   # 此处是 Prometheus 自身。
   scrape_configs:
     # 作业名称作为标签 `job=<job_name>` 被添加到从该配置抓取的任何时间序列。
     - job_name: "tgi"

       # metrics_path 默认值为 '/metrics'
       # scheme 默认值为 'http'.

       static_configs:
         - targets: ["localhost:9009"]

以下是另一个示例，从 Kubernetes 集群内的 TGI 微服务导出指标数据到 Prometheus：

.. code-block:: yaml

   scrape_configs:
     - job_name: "tgi"

       static_configs:
         - targets: ["llm-dependency-svc.default.svc.cluster.local:9009"]

3. 运行 Prometheus 服务器：
在不挂起进程的情况下运行 Prometheus 服务器：
```bash
nohup ./prometheus --config.file=./prometheus.yml &
```

4. 访问 Prometheus 用户界面：
通过以下 URL 访问 Prometheus 用户界面：

.. code-block:: bash

   http://localhost:9090/targets?search=

>注意：在启动 Prometheus 之前，请确保在指定端口（默认是 9090）上未运行其他进程。否则，Prometheus 将无法抓取指标。

在 Prometheus 用户界面中，您可以查看目标的状态和正在抓取的指标。您可以通过在搜索框中输入来搜索指标变量。

TGI 指标可以通过以下地址访问：

.. code-block:: bash

   http://${host_ip}:9009/metrics

设置 Grafana 仪表板
============================

Grafana 是一个用于可视化指标和创建仪表板的工具。可以用来创建自定义仪表板，显示 Prometheus 收集的指标。

要设置 Grafana 仪表板，请执行以下步骤：

1. 下载 Grafana：
   从官方网站下载 Grafana v8.0.6，并提取文件：

.. code-block:: bash

   wget https://dl.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz
   tar -zxvf grafana-11.0.0.linux-amd64.tar.gz

有关其他说明，请参见完整的 `Grafana 安装说明 <https://grafana.com/docs/grafana/latest/setup-grafana/installation/>`_。

2. 运行 Grafana 服务器：
   将目录更改为 Grafana 文件夹：

.. code-block:: bash

   cd grafana-11.0.0

运行 Grafana 服务器，不要挂起进程：

.. code-block:: bash

   nohup ./bin/grafana-server &

3. 访问 Grafana 仪表板用户界面：
   在您的浏览器中，通过以下 URL 访问 Grafana 仪表板用户界面：

.. code-block:: bash

   http://localhost:3000

>注意：在启动 Grafana 之前，请确保在端口 3000 上未运行其他进程。

使用默认凭证登录 Grafana：

.. code-block::

   username: admin
   password: admin

4. 将 Prometheus 添加为数据源：
   您需要为 Grafana 配置要抓取数据的数据源。单击“数据源”按钮，选择 Prometheus，然后指定 Prometheus URL ``http://localhost:9090``.

   然后，您需要上传仪表板配置的 JSON 文件。可以在 Grafana 用户界面中通过 ``主页 > 仪表板 > 导入仪表板`` 上传。这里提供一个示例 JSON 文件： `tgi_grafana.json <https://github.com/huggingface/text-generation-inference/blob/main/assets/tgi_grafana.json>`_

5. 查看仪表板：
   最后，在 Grafana 用户界面中打开仪表板，您将看到不同面板显示指标数据。

   以 TGI 微服务为例，您可以看到以下指标：
   * 第一个令牌的时间
   * 每个令牌的解码延迟
   * 吞吐量（生成的令牌/秒）
   * 每个提示的令牌数
   * 每个请求生成的令牌数

   您还可以实时监控到微服务的传入请求、每个令牌的响应时间等。

总结和下一步
=======================

待定
