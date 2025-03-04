.. _ChatQnA_Guide:

ChatQnA
######################### 

.. note:: Dieser Leitfaden befindet sich noch in der frühen Entwicklungsphase und ist ein Arbeitsdokument mit Platzhalterinhalten.

Overview
********

Chatbots sind ein weit verbreiteter Anwendungsfall, um die leistungsstarken Chat- und
Argumentationsfunktionen großer Sprachmodelle (LLMs) zu nutzen. Das ChatQnA-Beispiel
bietet Entwicklern den Ausgangspunkt, um mit der Arbeit im GenAI-Bereich zu beginnen.

Betrachten Sie es als das „Hallo Weltt“ der GenAI-Anwendungen und es kann für
Lösungen in weiten Unternehmensbereichen sowohl intern als auch extern genutzt werden.

Zweck
*******

Das ChatQnA-Beispiel verwendet eine Retrieval Augmented Generation (RAG)-Architektur,
die sich schnell zum Industriestandard für die Chatbot-Entwicklung entwickelt. Es
kombiniert die Vorteile einer Wissensdatenbank (über einen Vektorspeicher) und generativer
Modelle, um Halluzinationen zu reduzieren, aktuelle Informationen zu erhalten und
domänenspezifisches Wissen zu nutzen.

RAG schließt die Wissenslücke, indem es relevante Informationen dynamisch aus externen 
Quellen abruft und so sicherstellt, dass die generierten Antworten sachlich und aktuell 
bleiben. Der Kern dieser Architektur sind Vektordatenbanken, die für eine effiziente und 
semantische Abfrage von Informationen von entscheidender Bedeutung sind. Diese Datenbanken 
speichern Daten als Vektoren, sodass RAG schnell auf die relevantesten Dokumente oder 
Datenpunkte basierend auf semantischer Ähnlichkeit zugreifen kann.

Zentral für die RAG-Architektur ist die Verwendung eines generativen Modells, das für die 
Generierung von Antworten auf Benutzeranfragen verantwortlich ist. Das generative Modell 
wird anhand eines großen Korpus angepasster und relevanter Textdaten trainiert und ist 
in der Lage, menschenähnliche Antworten zu generieren. Entwickler können das generative 
Modell oder die Vektordatenbank problemlos durch ihre eigenen benutzerdefinierten Modelle 
oder Datenbanken ersetzen. Auf diese Weise können Entwickler Chatbots erstellen, die auf ihre 
spezifischen Anwendungsfälle und Anforderungen zugeschnitten sind. Durch die Kombination des 
generativen Modells mit der Vektordatenbank kann RAG genaue und kontextbezogene Antworten 
speziell auf die Anfragen Ihrer Benutzer bereitstellen.

Das ChatQnA-Beispiel ist als einfache, aber leistungsstarke Demonstration der RAG-Architektur 
konzipiert. Es ist ein großartiger Ausgangspunkt für Entwickler, die Chatbots erstellen möchten, 
die Benutzern genaue und aktuelle Informationen liefern können.

Um die gemeinsame Nutzung einzelner Dienste über mehrere GenAI-Anwendungen hinweg zu erleichtern, 
verwenden Sie den GenAI Microservices Connector (GMC), um Ihre Anwendung bereitzustellen. 
Neben der gemeinsamen Nutzung von Diensten unterstützt er auch die Angabe sequenzieller, 
paralleler und alternativer Schritte in einer GenAI-Pipeline. Dabei unterstützt er das dynamische 
Umschalten zwischen Modellen, die in jeder Phase einer GenAI-Pipeline verwendet werden. 
Beispielsweise könnte man innerhalb der ChatQnA-Pipeline mit GMC das im Embedder, 
Re-Ranker und/oder LLM verwendete Modell wechseln.Upstream Vanilla Kubernetes oder Red Hat OpenShift Container
Platform (RHOCP) können mit oder ohne GMC verwendet werden, während die Verwendung mit GMC zusätzliche Funktionen bietet.

ChatQnA bietet mehrere Bereitstellungsoptionen, darunter Einzelknotenbereitstellungen vor 
Ort oder in einer Cloud-Umgebung mit Hardware wie Xeon Scalable Processors, Gaudi-Servern, 
NVIDIA GPUs und sogar auf KI-PCs. Es unterstützt auch Kubernetes-Bereitstellungen mit und 
ohne GenAI Management Console (GMC) sowie Cloud-native Bereitstellungen mit RHOCP.

Wichtige Implementierungsdetails:
**************************

Einbettung:
  Der Prozess der Umwandlung von Benutzerabfragen in numerische Darstellungen, die als 
  Einbettung bezeichnet werden.
Vektordatenbank:
  Die Speicherung und Abfrage relevanter Datenpunkte mithilfe von Vektordatenbanken.
RAG-Architektur:
  Die Verwendung der RAG-Architektur zur Kombination von Wissensdatenbanken und generativen 
  Modellen für die Entwicklung von Chatbots mit relevanten und aktuellen Abfrageantworten.
Large Language Models (LLMs):
  Das Training und die Nutzung von LLMs zur Generierung von Antworten. Bereitstellungsoptionen:
Bereitstellungsoptionen:
  Produktionsbereite Bereitstellungsoptionen für das ChatQnA-Beispiel, einschließlich 
  Einzelknotenbereitstellungen und Kubernetes-Bereitstellungen.

Funktionsweise
************

Die ChatQnA-Beispiele folgen einem grundlegenden Informationsfluss im Chatbot-System,
beginnend mit der Benutzereingabe und durch die Komponenten Abrufen, Neubewerten und
Generieren, was letztlich zur Ausgabe des Bots führt.

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_architecture.png
:alt: ChatQnA-Architekturdiagramm

Dieses Diagramm veranschaulicht den Informationsfluss im Chatbot-System,
beginnend mit der Benutzereingabe und durch die Komponenten Abrufen, Analysieren und
Generieren, was letztlich zur Ausgabe des Bots führt.

Die Architektur folgt einer Reihe von Schritten, um Benutzeranfragen zu verarbeiten und Antworten zu generieren:

1. **Einbettung**: Die Benutzeranfrage wird zuerst in eine numerische
Darstellung umgewandelt, die als Einbettung bezeichnet wird. Diese Einbettung erfasst die semantische
Bedeutung der Anfrage und ermöglicht einen effizienten Vergleich mit anderen
Einbettungen.
## . **Vektordatenbank**: Die Einbettung wird dann verwendet, um eine Vektordatenbank zu durchsuchen,
die relevante Datenpunkte als Vektoren speichert. Die Vektordatenbank ermöglicht
ein effizientes und semantisches Abrufen von Informationen basierend auf der Ähnlichkeit
zwischen der Abfrageeinbettung und den gespeicherten Vektoren.
## . **Neubewertung**: Verwendet ein Modell, um die abgerufenen Daten nach ihrer Auffälligkeit zu bewerten.
Die Vektordatenbank ruft die relevantesten
Datenpunkte basierend auf der Abfrageeinbettung ab. Diese Datenpunkte können Dokumente,
Artikel oder andere relevante Informationen enthalten, die dabei helfen können, genaue
Antworten zu generieren.
## . **LLM**: Die abgerufenen Datenpunkte werden dann zur weiteren Verarbeitung an große Sprachmodelle
(LLM) übergeben. LLMs sind leistungsstarke generative Modelle,
die an einem großen Korpus von Textdaten trainiert wurden. Sie können
auf der Grundlage der Eingabedaten
menschenähnliche
Antworten generieren.
## . **Antwort generieren**: Die LLMs generieren eine Antwort basierend auf den Eingabedaten
und der Benutzerabfrage. Diese Antwort wird dann als Antwort des Chatbots an den Benutzer zurückgegeben.

Erwartete Ausgabe
===============

TBD

Validierungsmatrix und Voraussetzungen
====================================

See :doc:`/GenAIExamples/supported_examples`

Architektur
************

Die ChatQnA-Architektur wird unten angezeigt:

.. :: /GenAIExamples/ChatQnA/assets/img/chatqna_flow_chart.png
:alt: ChatQnA-Architekturdiagramm

Übersicht und Diagramm der Mikroservices
===================================

Eine GenAI-Anwendung oder -Pipeline in OPEA besteht normalerweise aus einer Sammlung von Mikroservices, um einen Megaservice zu erstellen, auf den über ein Gateway zugegriffen werden kann. Ein Mikroservice ist eine Komponente, die eine bestimmte Funktion oder Aufgabe ausführen soll. Mikroservices sind Bausteine, die die grundlegenden Dienste anbieten. Mikroservices fördern Modularität, Flexibilität und Skalierbarkeit im System. Ein Megaservice ist ein architektonisches Konstrukt höherer Ebene, das aus einem oder mehreren Mikroservices besteht und die Möglichkeit bietet, End-to-End-Anwendungen zusammenzustellen.
Das Gateway dient als Schnittstelle für den Zugriff der Benutzer. Das Gateway leitet eingehende Anfragen an die entsprechenden Microservices innerhalb der Megaservice-Architektur weiter. Weitere Informationen finden Sie unter „GenAI-Komponenten <https://github.com/opea-project/GenAIComps>“.

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


Bereitstellung
**********

Hier sind einige Bereitstellungsoptionen, abhängig von Ihrer Hardware und Umgebung.
Es sind sowohl Einzelknoten- als auch orchestrierte Mehrknotenkonfigurationen enthalten.
Wählen Sie diejenige aus, die Ihren Anforderungen am besten entspricht.

Einzelknoten
***********

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

Cloud Native
************

* Red Hat OpenShift Container Platform (RHOCP)

Fehlerbehebung
***************

1. Fehler beim https-Link der Browseroberfläche

F: Ich habe beispielsweise das ChatQnA-Beispiel in IBM Cloud gestartet und versuche, auf die Benutzeroberfläche zuzugreifen. Standardmäßig wird durch die Eingabe von :5173 https://:5173 aufgelöst. Chrome zeigt die folgende Warnmeldung an: xx.xx.xx.xx unterstützt keine sichere Verbindung

A: Das liegt daran, dass der Browser xx.xx.xx.xx:5173 standardmäßig in https://xx.xx.xx.xx:5173 auflöst. Um jedoch die Sicherheitsanforderungen zu erfüllen, müssen Benutzer ein Zertifikat bereitstellen, um die HTTPS-Unterstützung in einigen Cloud-Umgebungen zu aktivieren. OPEA bietet standardmäßig HTTP-Dienste, unterstützt aber auch HTTPS. Um HTTPS zu aktivieren, können Sie die Zertifikatdateipfade in der MicroService-Klasse angeben. Weitere Einzelheiten finden Sie im `Quellcode <https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/micro_service.py#L33>`_.

2. Bei anderen Problemen lesen Sie bitte das `Dokument <https://opea-project.github.io/latest/GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi/how_to_validate_service.html>`_.

Überwachung
**********

Nachdem Sie nun das ChatQnA-Beispiel bereitgestellt haben, sprechen wir über die Überwachung der Leistung der Microservices in der ChatQnA-Pipeline.

Die Überwachung der Leistung von Microservices ist entscheidend, um den reibungslosen Betrieb der generativen KI-Systeme sicherzustellen. Durch die Überwachung von Metriken wie Latenz und Durchsatz können Sie Engpässe identifizieren, Anomalien erkennen und die Leistung einzelner Microservices optimieren. Auf diese Weise können wir alle Probleme proaktiv angehen und sicherstellen, dass die ChatQnA-Pipeline effizient läuft.

Dieses Dokument hilft Ihnen zu verstehen, wie Sie die Latenz, den Durchsatz und andere Metriken verschiedener Microservices in Echtzeit überwachen können. Sie verwenden **Prometheus** und **Grafana**, beides Open-Source-Toolkits, um Metriken zu sammeln und sie in einem Dashboard zu visualisieren.

Richten Sie den Prometheus-Server ein
=============================

Prometheus ist ein Tool zum Aufzeichnen von Echtzeitmetriken und wurde speziell für die Überwachung von Microservices und die Ausgabe von Warnungen auf Grundlage ihrer Metriken entwickelt.

Der Endpunkt „/metrics“ auf dem Port, auf dem jeder Microservice ausgeführt wird, stellt die Metriken im Prometheus-Format bereit. Der Prometheus-Server sammelt diese Metriken und speichert sie in seiner Zeitreihendatenbank. Metriken für den Text Generation Interface (TGI)-Dienst sind beispielsweise verfügbar unter:

.. code-block:: bash

   http://${host_ip}:9009/metrics

Richten Sie den Prometheus-Server ein:

1. Laden Sie Prometheus herunter:
Laden Sie Prometheus v2.52.0 von der offiziellen Site herunter und extrahieren Sie die Dateien:

.. code-block:: bash

wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.52.0.linux-amd64.tar.gz

2. Konfigurieren Sie Prometheus:
Wechseln Sie das Verzeichnis zum Prometheus-Ordner:

.. code-block:: bash

cd prometheus-2.52.0.linux-amd64

Bearbeiten Sie die Datei `prometheus.yml`:

.. code-block:: bash

vim prometheus.yml

Ändern Sie die ``job_name`` zum Namen des Microservice, den Sie überwachen möchten. Ändern Sie auch die ``targets`` in den Job-Zielendpunkt dieses Microservice. Stellen Sie sicher, dass der Dienst ausgeführt wird und der Port geöffnet ist und dass er die Metriken, die der Prometheus-Konvention entsprechen, am Endpunkt ``/metrics`` verfügbar macht.

Hier ist ein Beispiel für den Export von Metrikdaten von einem TGI-Mikroservice nach Prometheus:

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

Hier ist ein weiteres Beispiel für den Export von Messdaten aus einem TGI-Mikroservice (innerhalb eines Kubernetes-Clusters) nach Prometheus:

.. code-block:: yaml

   scrape_configs:
     - job_name: "tgi"

       static_configs:
         - targets: ["llm-dependency-svc.default.svc.cluster.local:9009"]

3. Führen Sie den Prometheus-Server aus:
Führen Sie den Prometheus-Server aus, ohne den Prozess zu unterbrechen:
```bash
nohup ./prometheus --config.file=./prometheus.yml &
```

4. Greifen Sie auf die Prometheus-Benutzeroberfläche zu.
Greifen Sie unter der folgenden URL auf die Prometheus-Benutzeroberfläche zu:

.. code-block:: bash

   http://localhost:9090/targets?search=

>Hinweis: Stellen Sie vor dem Starten von Prometheus sicher, dass auf dem angegebenen Port (Standard ist 9090) keine anderen Prozesse ausgeführt werden. Andernfalls kann Prometheus die Metriken nicht scrapen.

Auf der Prometheus-Benutzeroberfläche können Sie den Status der Ziele und die gescrapten Metriken sehen. Sie können nach einer Metrikvariable suchen, indem Sie sie in die Suchleiste eingeben.

Die TGI-Metriken sind unter folgender Adresse abrufbar:

.. code-block:: bash

   http://${host_ip}:9009/metrics

Richten Sie das Grafana-Dashboard ein
=============================

Grafana ist ein Tool zum Visualisieren von Metriken und Erstellen von Dashboards. Es kann verwendet werden, um benutzerdefinierte Dashboards zu erstellen, die die von Prometheus erfassten Metriken anzeigen.

Um das Grafana-Dashboard einzurichten, befolgen Sie diese Schritte:

1. Laden Sie Grafana herunter:
Laden Sie Grafana v8.0.6 von der offiziellen Site herunter und extrahieren Sie die Dateien:

.. code-block:: bash

wget https://dl.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz
tar -zxvf grafana-11.0.0.linux-amd64.tar.gz

Weitere Anweisungen finden Sie in den vollständigen `Grafana-Installationsanweisungen <https://grafana.com/docs/grafana/latest/setup-grafana/installation/>`_.

2. Führen Sie den Grafana-Server aus:

Wechseln Sie das Verzeichnis zum Grafana-Ordner:

.. code-block:: bash

cd grafana-11.0.0

Führen Sie den Grafana-Server aus, ohne den Prozess zu unterbrechen:

.. code-block:: bash

nohup ./bin/grafana-server &

3. Greifen Sie auf die Grafana-Dashboard-Benutzeroberfläche zu:

Greifen Sie in Ihrem Browser unter der folgenden URL auf die Grafana-Dashboard-Benutzeroberfläche zu:

.. code-block:: bash

http://localhost:3000

>Hinweis: Stellen Sie vor dem Starten von Grafana sicher, dass keine anderen Prozesse auf Port 3000 ausgeführt werden.

Melden Sie sich mit den Standardanmeldeinformationen bei Grafana an:

.. Codeblock::

Benutzername: admin
Passwort: admin

4. Fügen Sie Prometheus als Datenquelle hinzu:
Sie müssen die Datenquelle konfigurieren, aus der Grafana Daten abrufen soll. Klicken Sie auf die Schaltfläche „Datenquelle“, wählen Sie Prometheus aus und geben Sie die Prometheus-URL „http://localhost:9090“ an.

Anschließend müssen Sie eine JSON-Datei für die Konfiguration des Dashboards hochladen. Sie können sie in der Grafana-Benutzeroberfläche unter „Startseite > Dashboards > Dashboard importieren“ hochladen. Eine Beispiel-JSON-Datei wird hier unterstützt: „tgi_grafana.json <https://github.com/huggingface/text-generation-inference/blob/main/assets/tgi_grafana.json>“_

5. Zeigen Sie das Dashboard an:
Öffnen Sie abschließend das Dashboard in der Grafana-Benutzeroberfläche. Sie sehen verschiedene Bereiche, in denen die Messdaten angezeigt werden.

Am Beispiel des TGI-Mikrodienstes können Sie die folgenden Kennzahlen sehen:
* Zeit bis zum ersten Token
* Latenzzeit pro Token-Dekodierung
* Durchsatz (generierte Token/Sek.)
* Anzahl der Token pro Eingabeaufforderung
* Anzahl der generierten Token pro Anfrage

Sie können auch die eingehenden Anfragen an den Mikrodienst, die Antwortzeit pro Token usw. in Echtzeit überwachen.

Zusammenfassung und nächste Schritte
========================

TBD