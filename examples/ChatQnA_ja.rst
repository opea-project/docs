.. _ChatQnA_Guide:

ChatQnA
####################

.. note:: このガイドは初期開発段階にあり、プレースホルダー コンテンツを含む進行中の作業です。

概要
********

チャットボットは、大規模言語モデル(LLM) の強力なチャットおよび推論機能を活用するために広く採用されているユースケースです。ChatQnA の例は、開発者が GenAI 空間で作業を開始できる出発点を提供します。GenAI アプリケーションの「hello world」と考えてください。社内外で幅広い企業の垂直ソリューションに活用できます。

目的
*******

ChatQnA の例は、検索強化生成(RAG) アーキテクチャを使用しています。このアーキテクチャは、チャットボット開発の産業標準になりつつあります。知識ベース(ベクトルストレージを介して) と生成モデルの利点を組み合わせ、幻覚を減らし、最新の情報を維持し、ドメイン特有の知識を活用します。

RAG は、外部ソースから関連情報を動的に取得することによって知識のギャップを埋め、生成される応答が事実に基づき最新の状態を保つことを保証します。このアーキテクチャのコアは、効率的で意味的な情報検索を可能にするベクトルデータベースです。これらのデータベースは、データをベクトルとして保存し、RAG が意味的な類似性に基づいて最も関連性の高い文書やデータポイントに迅速にアクセスできるようにします。

RAG アーキテクチャの中核には、ユーザーのクエリに対する応答を生成する生成モデルの使用があります。生成モデルは、カスタマイズされた関連テキストデータの大規模なコーパスでトレーニングされており、人間に似た応答を生成する能力があります。開発者は、生成モデルやベクトルデータベースを自分のカスタムモデルやデータベースに簡単に入れ替えることができます。これにより、特定のユースケースや要件に合わせたチャットボットを構築することができます。生成モデルとベクトルデータベースを組み合わせることで、RAG はユーザーのクエリに特有の正確で状況に適した応答を提供できます。

ChatQnA の例は、RAG アーキテクチャのシンプルで強力なデモになるように設計されています。正確で最新の情報をユーザーに提供できるチャットボットを構築したい開発者にとって素晴らしい出発点です。

複数の GenAI アプリケーション間で個別のサービスを共有しやすくするために、GenAI マイクロサービス コネクタ(GMC) を使用してアプリケーションをデプロイします。サービス共有に加えて、GenAI パイプライン内で順次、並列、および代替のステップを指定することもサポートします。こうすることで、GenAI パイプラインのあらゆるステージで使用されるモデル間の動的な切り替えがサポートされます。たとえば、ChatQnA パイプライン内では、GMCを使用して埋め込み、再ランク付け、またはLLMで使用されるモデルを切り替えることができます。アップストリームのバニラKubernetesまたはRed Hat OpenShiftコンテナプラットフォーム(RHOCP)は、GMCの有無にかかわらず使用できますが、GMCを使用することで追加機能が提供されます。

ChatQnA は、Xeon スケーラブルプロセッサ、Gaudi サーバー、NVIDIA GPU、および AI PC などのハードウェアを使用して、オンプレミスまたはクラウド環境での単一ノードデプロイを含む複数のデプロイメントオプションを提供します。また、GenAI マネジメントコンソール(GMC) の有無にかかわらず Kubernetes デプロイメントおよび RHOCP を使用したクラウドネイティブ デプロイメントもサポートが含まれます。

主要実装の詳細
**************************

埋め込み:
ユーザーのクエリを埋め込みと呼ばれる数値表現に変換するプロセス。

ベクトルデータベース:
ベクトルデータベースを利用して関連データポイントを保存し、取得します。

RAG アーキテクチャ:
RAG アーキテクチャを利用して知識ベースと生成モデルを統合し、関連性があり最新のクエリ応答を持つチャットボットを開発します。

大規模言語モデル(LLM): 
応答生成のための LLM の訓練と利用。

デプロイオプション:
ChatQnA の例に対してプロダクション対応のデプロイオプション、単一ノードデプロイメントおよび Kubernetes デプロイメントを含む。

動作原理
************

ChatQnA の例では、チャットボットシステム内の基本的な情報フローに従い、ユーザー入力から始まり、取得、再ランキング、生成の各要素を経て、最終的にボットの出力となります。

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_architecture.png
   :alt: ChatQnA アーキテクチャ図

この図は、ユーザー入力から始まり、取得、分析、生成要素を経て、最終的にボットの出力に至る情報フローを示します。

アーキテクチャは、ユーザーのクエリを処理して応答を生成するために一連の手続きを踏襲します。

1. **埋め込み**: ユーザーのクエリは、まず埋め込みと呼ばれる数値表現に変換されます。この埋め込みは、クエリの意味的な意義を捕え、他の埋め込みと効率的に比較できるようにします。
#. **ベクトルデータベース**: その埋め込みを利用してベクトルデータベースを検索します。ベクトルデータベースは、関連するデータポイントをベクトルとして保存します。ベクトルデータベースは、クエリ埋め込みと保存されたベクトルの類似性に基づいて、情報を効率的かつ意味論的に検索できるようにします。
#. **再ランキング**: モデルを使用して、取得したデータの重要度に基づいてランクを付けます。ベクトルデータベースは、クエリ埋め込みを基に最も関連性のあるデータポイントを取得します。これらのデータポイントには、文書、記事、あるいは正確な回答を生成するのに役立つその他の情報が含まれることがあります。
#. **LLM**: 取得したデータポイントは、追加処理のために大規模言語モデル(LLM)に渡されます。LLMは、大規模なテキストデータコーパスに基づいて学習された強力な生成モデルです。入力データに基づいて、人間らしい応答を生成することができます。
#. **応答生成**: LLMは、入力データとユーザーのクエリに基づいて応答を生成します。この応答は、チャットボットの回答としてユーザーに返されます。

期待される出力
===============

TBD

検証マトリックスと前提条件
===================================

参照: :doc:`/GenAIExamples/supported_examples`

アーキテクチャ
************

ChatQnA アーキテクチャは以下のとおりです。

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_flow_chart.png
   :alt: ChatQnA アーキテクチャ図

マイクロサービスの概要と図
================================

OPEAのGenAIアプリケーションまたはパイプラインは、一般にゲートウェイ経由でアクセスされるメガサービスを作成するマイクロサービスのコレクションで構成されます。マイクロサービスは特定の機能やタスクを実行するように設計されたコンポーネントです。マイクロサービスは基本的なサービスを提供するビルディングブロックです。マイクロサービスはシステムにモジュール性、柔軟性、スケーラビリティを促進します。メガサービスは1つ以上のマイクロサービスで構成される高レベルのアーキテクチャ構造であり、エンドツーエンドのアプリケーションを構成する能力を提供します。
ゲートウェイはユーザーがアクセスできるインターフェースとして機能します。ゲートウェイは、メガサービスアーキテクチャ内の適切なマイクロサービスに着信要求をルーティングします。詳細については `GenAI構成要素 <https://github.com/opea-project/GenAIComps>`_ を参照してください。

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


デプロイ
**********

ハードウェアおよび環境に応じたいくつかのデプロイメントオプションを次に示します。単一ノード構成とオーケストレーションされたマルチノード構成の両方が含まれます。要件に最適なものを選択してください。

単一ノード
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

クラウドネイティブ
************

* Red Hat OpenShift Container Platform (RHOCP)

トラブルシューティング
****************

1. ブラウザー インターフェースの https リンクが失敗しました

   質問:たとえば、IBM Cloud で ChatQnA の例を開始し、UI インターフェースにアクセスしようとしています。デフォルトで :5173 を入力すると https://:5173 に変換されます。Chrome には次の警告メッセージが表示されます：xx.xx.xx.xx は安全な接続をサポートしていません

   回答: これは、ブラウザーがデフォルトで xx.xx.xx.xx:5173 を https://xx.xx.xx.xx:5173 に解決するためです。ただし、セキュリティ要件を満たすには、一部のクラウド環境ではユーザーが証明書をデプロイして HTTPS サポートを有効にする必要があります。OPEA はデフォルトで HTTP サービスを提供していますが、HTTPS もサポートしています。HTTPS を有効にするには、MicroService クラスで証明書ファイルのパスを指定できます。 詳細については、`ソース コード <https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/micro_service.py#L33>`_ を参照してください。

2. その他のトラブルについては、`doc <https://opea-project.github.io/latest/GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi/how_to_validate_service.html>`_ を確認してください。

モニタリング
**********

ChatQnA の例をデプロイしたので、ChatQnA パイプラインのマイクロサービスのパフォーマンスをモニタリングする方法について説明します。

マイクロサービスのパフォーマンスをモニタリングすることは、生成 AI システムの円滑な運用を確保するために不可欠です。レイテンシやスループットなどのメトリックをモニタリングすることで、ボトルネックを特定し、異常を検出し、個々のマイクロサービスのパフォーマンスを最適化できます。これにより、問題に対処して ChatQnA パイプラインが効率的に実行されることが保証されます。

この文書は、さまざまなマイクロサービスのレイテンシ、スループット、および他のメトリックをリアルタイムでモニタリングする方法を理解するのに役立ちます。オープンソースのツールキットである**Prometheus** と**Grafana**を使用して、メトリックを収集し、ダッシュボードで視覚化します。

Prometheus サーバーをセットアップする
=============================

Prometheusは、リアルタイムメトリックを記録するために使用されるツールで、マイクロサービスを監視してメトリックに基づいてアラートを通知するように特に設計されています。

各マイクロサービスを実行するポートの `/metrics` エンドポイントは、Prometheus 形式でメトリックを公開します。Prometheus サーバーはこれらのメトリックをスクレイピングし、時系列データベースに保存します。例えば、Text Generation Interface (TGI) サービスのメトリックは次の場所で利用可能です。

.. code-block:: bash

   http://${host_ip}:9009/metrics

Prometheus サーバーを設定する：

1. Prometheus をダウンロードする：
公式サイトから Prometheus v2.52.0 をダウンロードし、ファイルを抽出します。

.. code-block:: bash

   wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
   tar -xvzf prometheus-2.52.0.linux-amd64.tar.gz

2. Prometheus を構成する：
ディレクトリを Prometheus フォルダーに変更します。

.. code-block:: bash

   cd prometheus-2.52.0.linux-amd64

`prometheus.yml` ファイルを編集します。

.. code-block:: bash

   vim prometheus.yml

``job_name`` を監視するマイクロサービスの名前に変更します。 ``targets`` をそのマイクロサービスのターゲットエンドポイントに変更します。サービスが実行中でポートが開いており、 ``/metrics`` エンドポイントで Prometheus 規則に従うメトリックが公開されていることを確認してください。

以下は、TGI マイクロサービスから Prometheus にメトリック データをエクスポートする例です。

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

以下は、TGI マイクロサービス (Kubernetes クラスター内) から Prometheus にメトリック データをエクスポートする別の例です。

.. code-block:: yaml

   scrape_configs:
     - job_name: "tgi"

       static_configs:
         - targets: ["llm-dependency-svc.default.svc.cluster.local:9009"]

3. Prometheus サーバーを実行する：
プロセスを中断せずに Prometheus サーバーを実行します。

```bash
nohup ./prometheus --config.file=./prometheus.yml &
```

4. Prometheus UI にアクセスする
次の URL で Prometheus UI にアクセスしてください。

.. code-block:: bash

   http://localhost:9090/targets?search=

>注： Prometheus を起動する前に、指定されたポート（デフォルトは 9090）で他のプロセスが実行されていないことを確認してください。そうでないと Prometheus はメトリックをスクリーピングできません。

Prometheus UI では、ターゲットのステータスとスクレイピングされているメトリックを確認できます。検索バーに入力してメトリック変数を検索できます。

TGI メトリックには、次の場所からアクセスできます。

.. code-block:: bash

   http://${host_ip}:9009/metrics

Grafana ダッシュボードを設定する
=============================

Grafanaは、メトリックの視覚化とダッシュボードの作成に使用されるツールです。Prometheus によって収集されたメトリックを表示するカスタム ダッシュボードを作成するために使用できます。

Grafana ダッシュボードを設定するには、次の手順に従います。

1. Grafana をダウンロードします。
公式サイトから Grafana v8.0.6 をダウンロードし、ファイルを抽出します。

.. code-block:: bash

   wget https://dl.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz
   tar -zxvf grafana-11.0.0.linux-amd64.tar.gz

詳細な手順については、完全な `Grafana インストール手順 <https://grafana.com/docs/grafana/latest/setup-grafana/installation/>`_ を参照してください。

2. Grafana サーバーを実行します：
ディレクトリを Grafana フォルダーに変更します。

.. code-block:: bash

   cd grafana-11.0.0

プロセスを中断せずに Grafana サーバーを実行します。

.. code-block:: bash

   nohup ./bin/grafana-server &

3. Grafana ダッシュボード UI にアクセスします：
ブラウザで、次の URL から Grafana ダッシュボード UI にアクセスします。

.. code-block:: bash

   http://localhost:3000

>注：Grafana を起動する前に、ポート 3000 で他のプロセスが実行されていないことを確認してください。

デフォルトの認証情報を使用して Grafana にログインします。

.. code-block::

   username: admin
   password: admin

4. Prometheus をデータ ソースとして追加します：
Grafana がデータを取得するデータ ソースを構成する必要があります。[データ ソース] ボタンをクリックし、Prometheus を選択して、Prometheus URL ``http://localhost:9090`` を指定します。

次に、ダッシュボードの構成用の JSON ファイルをアップロードする必要があります。Grafana UI の ``Home > Dashboards > Import dashboard`` でアップロードできます。サンプル JSON ファイルは、こちらでサポートされています: `tgi_grafana.json <https://github.com/huggingface/text-generation-inference/blob/main/assets/tgi_grafana.json>`_
5. ダッシュボードの表示：
最後に、Grafana UI でダッシュボードを開くと、メトリック データを表示するさまざまなパネルが表示されます。

TGI マイクロサービスを例にとると、次のメトリックを確認できます。

* 最初のトークンまでの時間
* トークンごとのデコード レイテンシ
* スループット (生成されたトークン/秒)
* プロンプトごとのトークンの数
* リクエストごとの生成されたトークンの数

マイクロサービスへの受信リクエスト、トークンごとの応答時間などをリアルタイムで監視することもできます。

概要と次のステップ
=========================

TBD