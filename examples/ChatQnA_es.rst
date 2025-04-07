.. _ChatQnA_Guide:

ChatQnA
####################

.. note:: Esta guía se encuentra en su etapa inicial de desarrollo y es un trabajo en progreso con contenido de marcador de posición.

Descripción general
********

Los chatbots son un caso de uso ampliamente adoptado para aprovechar las potentes capacidades de chat y razonamiento de los modelos de lenguaje grandes (LLM). El ejemplo de ChatQnA ofrece el punto de partida para que los desarrolladores comiencen a trabajar en el espacio GenAI. Considérelo el "hola mundo" de las aplicaciones GenAI, y se puede aprovechar para soluciones en verticales empresariales amplias, tanto internas como externas.

Propósito
*******

El ejemplo de ChatQnA utiliza la arquitectura de generación aumentada de recuperación (RAG), que rápidamente se está convirtiendo en el estándar de la industria para el desarrollo de chatbots. Combina los beneficios de una base de conocimiento (a través de un almacén de vectores) y modelos generativos para reducir las alucinaciones, mantener la información actualizada y aprovechar el conocimiento específico del dominio.

RAG cierra la brecha de conocimiento al buscar dinámicamente información relevante de fuentes externas, lo que garantiza que las respuestas generadas sigan siendo objetivas y actuales. El núcleo de esta arquitectura son las bases de datos vectoriales, que son fundamentales para permitir una recuperación eficiente y semántica de la información. Estas bases de datos almacenan datos como vectores, lo que permite a RAG acceder rápidamente a los documentos o puntos de datos más pertinentes en función de la similitud semántica.

Un elemento central de la arquitectura de RAG es el uso de un modelo generativo, que es responsable de generar respuestas a las consultas de los usuarios. El modelo generativo se entrena en un gran corpus de datos de texto personalizados y relevantes y es capaz de generar respuestas similares a las humanas. Los desarrolladores pueden cambiar fácilmente el modelo generativo o la base de datos vectorial por sus propios modelos o bases de datos personalizados. Esto permite a los desarrolladores crear chatbots que se adapten a sus casos de uso y requisitos específicos. Al combinar el modelo generativo con la base de datos vectorial, RAG puede proporcionar respuestas precisas y contextualmente relevantes específicas para las consultas de sus usuarios.

El ejemplo de ChatQnA está diseñado para ser una demostración simple, pero poderosa, de la arquitectura de RAG. Es un excelente punto de partida para los desarrolladores que buscan crear chatbots que puedan proporcionar información precisa y actualizada a los usuarios.

Para facilitar el uso compartido de servicios individuales entre múltiples aplicaciones GenAI, use el Conector de microservicios GenAI (GMC) para implementar su aplicación. Además de compartir servicios, también admite la especificación de pasos secuenciales, paralelos y alternativos en una canalización GenAI. Al hacerlo, admite el cambio dinámico entre los modelos utilizados en cualquier etapa de una canalización GenAI. Por ejemplo, dentro de la canalización ChatQnA, utilizando GMC se podría cambiar el modelo utilizado en el integrador, el reclasificador y/o el LLM. Upstream Vanilla Kubernetes o Red Hat OpenShift Container Platform (RHOCP) se pueden utilizar con o sin GMC, mientras que el uso con GMC proporciona funciones adicionales.

ChatQnA ofrece varias opciones de implementación, incluidas implementaciones de un solo nodo en las instalaciones o en un entorno de nube utilizando hardware como procesadores escalables Xeon, servidores Gaudi, GPU NVIDIA e incluso en PC con inteligencia artificial. También admite implementaciones de Kubernetes con y sin la consola de administración GenAI (GMC), así como implementaciones nativas de la nube utilizando RHOCP.

Detalles clave de implementación
**************************

Incorporación:
El proceso de transformar las consultas de los usuarios en representaciones numéricas llamadas incrustaciones.

Base de datos vectorial:
El almacenamiento y la recuperación de puntos de datos relevantes utilizando bases de datos vectoriales.

Arquitectura RAG:
El uso de la arquitectura RAG para combinar bases de conocimiento y modelos generativos para el desarrollo de chatbots con respuestas de consultas relevantes y actualizadas.

Modelos de lenguaje grandes (LLM):
El entrenamiento y la utilización de LLM para generar respuestas.

Opciones de implementación:
Opciones de implementación listas para producción para el ejemplo ChatQnA, incluidas implementaciones de un solo nodo e implementaciones de Kubernetes.

Cómo funciona
************

Los ejemplos de ChatQnA siguen un flujo básico de información en el sistema de chatbot, que comienza con la entrada del usuario y pasa por los componentes de recuperación, reclasificación y generación, lo que finalmente da como resultado el resultado del bot.

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_architecture.png
:alt: Diagrama de arquitectura de ChatQnA

Este diagrama ilustra el flujo de información en el sistema de chatbot, que comienza con la entrada del usuario y pasa por los componentes de recuperación, análisis y generación, lo que finalmente da como resultado el resultado del bot.

La arquitectura sigue una serie de pasos para procesar las consultas del usuario y generar respuestas:

1. **Incorporación**: la consulta del usuario primero se transforma en una representación numérica llamada incrustación. Esta incrustación captura el significado semántico de la consulta y permite una comparación eficiente con otras incrustaciones.
#. **Base de datos de vectores**: la incrustación se utiliza para buscar en una base de datos de vectores, que almacena puntos de datos relevantes como vectores. La base de datos de vectores permite una recuperación eficiente y semántica de información basada en la similitud entre la incrustación de la consulta y los vectores almacenados.
#. **Reclasificador**: utiliza un modelo para clasificar los datos recuperados según su relevancia. La base de datos de vectores recupera los puntos de datos más relevantes según la incrustación de la consulta. Estos puntos de datos pueden incluir documentos, artículos o cualquier otra información relevante que pueda ayudar a generar respuestas precisas.
#. **LLM**: los puntos de datos recuperados se pasan a modelos de lenguaje grandes (LLM) para su posterior procesamiento. Los LLM son modelos generativos poderosos que han sido entrenados en un gran corpus de datos de texto. Pueden generar respuestas similares a las humanas según los datos de entrada.
#. **Generar respuesta**: los LLM generan una respuesta según los datos de entrada y la consulta del usuario. Luego, esta respuesta se devuelve al usuario como respuesta del chatbot.

Resultados esperados
===============

Por determinar

Matriz de validación y requisitos previos
===================================

See :doc:`/GenAIExamples/supported_examples`

Arquitectura
************

La arquitectura de ChatQnA se muestra a continuación:

.. figure:: /GenAIExamples/ChatQnA/assets/img/chatqna_flow_chart.png
:alt: Diagrama de arquitectura de ChatQnA

Esquema y diagrama de microservicio
================================

Una aplicación o canalización GenAI en OPEA generalmente consta de una colección de microservicios para crear un megaservicio, al que se accede a través de una puerta de enlace. Un microservicio es un componente diseñado para realizar una función o tarea específica. Los microservicios son bloques de construcción que ofrecen los servicios fundamentales. Los microservicios promueven la modularidad, la flexibilidad y la escalabilidad en el sistema. Un megaservicio es una construcción arquitectónica de nivel superior compuesta por uno o más microservicios, que proporciona la capacidad de ensamblar aplicaciones de extremo a extremo. La puerta de enlace sirve como interfaz para que los usuarios accedan. La puerta de enlace dirige las solicitudes entrantes a los microservicios correspondientes dentro de la arquitectura de megaservicios. Consulte `Componentes GenAI <https://github.com/opea-project/GenAIComps>`_ para obtener más información.

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


Implementación
**********

A continuación se muestran algunas opciones de implementación según el hardware y el entorno. Incluye configuraciones de nodo único y de nodos múltiples orquestados. Elija la que mejor se adapte a sus requisitos.

Nodo único
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

Nativo de la nube
************

* Red Hat OpenShift Container Platform (RHOCP)

Solución de problemas
***************

1. Error en el enlace https de la interfaz del navegador

P: Por ejemplo, inicié el ejemplo ChatQnA en IBM Cloud e intenté acceder a la interfaz de la IU. De manera predeterminada, al escribir :5173 se resuelve https://:5173. Chrome muestra el siguiente mensaje de advertencia: xx.xx.xx.xx no admite una conexión segura

R: Esto se debe a que, de manera predeterminada, el navegador resuelve xx.xx.xx.xx:5173 en https://xx.xx.xx.xx:5173. Pero para cumplir con los requisitos de seguridad, los usuarios deben implementar un certificado para habilitar la compatibilidad con HTTPS en algunos entornos de nube. OPEA proporciona servicios HTTP de manera predeterminada, pero también admite HTTPS. Para habilitar HTTPS, puede especificar las rutas de archivo del certificado en la clase MicroService. Para obtener más detalles, consulte el código fuente <https://github.com/opea-project/GenAIComps/blob/main/comps/cores/mega/micro_service.py#L33>`_.

2. Para otros problemas, consulte la documentación <https://opea-project.github.io/latest/GenAIExamples/ChatQnA/docker_compose/intel/hpu/gaudi/how_to_validate_service.html>`_.


Monitoreo
**********

Ahora que implementó el ejemplo de ChatQnA, hablemos sobre el monitoreo del rendimiento de los microservicios en el pipeline de ChatQnA.

El monitoreo del rendimiento de los microservicios es crucial para garantizar el funcionamiento sin problemas de los sistemas de IA generativa. Al monitorear métricas como la latencia y el rendimiento, puede identificar cuellos de botella, detectar anomalías y optimizar el rendimiento de microservicios individuales. Esto nos permite abordar de manera proactiva cualquier problema y garantizar que el pipeline de ChatQnA se ejecute de manera eficiente.

Este documento lo ayudará a comprender cómo monitorear en tiempo real la latencia, el rendimiento y otras métricas de diferentes microservicios. Utilizará **Prometheus** y **Grafana**, ambos kits de herramientas de código abierto, para recopilar métricas y visualizarlas en un panel.

Configurar el servidor Prometheus
============================

Prometheus es una herramienta que se utiliza para registrar métricas en tiempo real y está diseñada específicamente para supervisar microservicios y generar alertas en función de sus métricas.

El punto de conexión `/metrics` en el puerto que ejecuta cada microservicio expone las métricas en formato Prometheus. El servidor Prometheus recopila estas métricas y las almacena en su base de datos de series temporales. Por ejemplo, las métricas para el servicio Text Generation Interface (TGI) están disponibles en:

.. code-block:: bash

http://${host_ip}:9009/metrics

Configurar el servidor Prometheus:

1. Descarga Prometheus:
Descarga Prometheus v2.52.0 desde el sitio oficial y extrae los archivos:

.. code-block:: bash

   wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
   tar -xvzf prometheus-2.52.0.linux-amd64.tar.gz

2. Configurar Prometheus:
Cambie el directorio a la carpeta Prometheus:

.. code-block:: bash

   cd prometheus-2.52.0.linux-amd64

Edite el archivo `prometheus.yml`:

.. code-block:: bash

   vim prometheus.yml

Cambie ``job_name`` por el nombre del microservicio que desea supervisar. Cambie también ``targets`` por el punto final del objetivo del trabajo de ese microservicio. Asegúrese de que el servicio se esté ejecutando y que el puerto esté abierto, y que exponga las métricas que siguen la convención de Prometheus en el punto final ``/metrics``.

A continuación, se muestra un ejemplo de exportación de datos de métricas desde un microservicio TGI a Prometheus:

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

Aquí hay otro ejemplo de exportación de datos de métricas desde un microservicio TGI (dentro de un clúster de Kubernetes) a Prometheus:

.. code-block:: yaml

   scrape_configs:
     - job_name: "tgi"

       static_configs:
         - targets: ["llm-dependency-svc.default.svc.cluster.local:9009"]

3. Ejecute el servidor Prometheus:
Ejecute el servidor Prometheus, sin interrumpir el proceso:
```bash
nohup ./prometheus --config.file=./prometheus.yml &
```

4. Acceda a la interfaz de usuario de Prometheus
Acceda a la interfaz de usuario de Prometheus en la siguiente URL:

.. code-block:: bash

   http://localhost:9090/targets?search=

>Nota: Antes de iniciar Prometheus, asegúrese de que no haya otros procesos ejecutándose en el puerto designado (el valor predeterminado es 9090). De lo contrario, Prometheus no podrá extraer las métricas.

En la interfaz de usuario de Prometheus, puede ver el estado de los objetivos y las métricas que se están extrayendo. Puede buscar una variable de métricas escribiéndola en la barra de búsqueda.

Se puede acceder a las métricas de TGI en:

.. code-block:: bash

   http://${host_ip}:9009/metrics

Configurar el panel de Grafana
============================

Grafana es una herramienta que se utiliza para visualizar métricas y crear paneles. Se puede utilizar para crear paneles personalizados que muestren las métricas recopiladas por Prometheus.

Para configurar el panel de control de Grafana, siga estos pasos:

1. Descargue Grafana:
Descargue Grafana v8.0.6 desde el sitio oficial y extraiga los archivos:

.. code-block:: bash

wget https://dl.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz
tar -zxvf grafana-11.0.0.linux-amd64.tar.gz

Para obtener instrucciones adicionales, consulte las `Instrucciones de instalación de Grafana completas <https://grafana.com/docs/grafana/latest/setup-grafana/installation/>`_.

2. Ejecute el servidor Grafana:
Cambie el directorio a la carpeta Grafana:

.. code-block:: bash

cd grafana-11.0.0

Ejecute el servidor Grafana sin interrumpir el proceso:

.. code-block:: bash

nohup ./bin/grafana-server &

3. Acceda a la interfaz de usuario del panel de control de Grafana:
En su navegador, acceda a la interfaz de usuario del panel de control de Grafana en la siguiente URL:

.. code-block:: bash

http://localhost:3000

>Nota: antes de iniciar Grafana, asegúrese de que no haya otros procesos ejecutándose en el puerto 3000.

Inicia sesión en Grafana con las credenciales predeterminadas:

.. code-block::

username: admin
password: admin

4. Agrega Prometheus como fuente de datos:
Debes configurar la fuente de datos de la que Grafana extraerá datos. Haz clic en el botón "Fuente de datos", selecciona Prometheus y especifica la URL de Prometheus ``http://localhost:9090``.

Luego, debes cargar un archivo JSON para la configuración del panel. Puedes cargarlo en la IU de Grafana en ``Inicio > Paneles > Importar panel``. Aquí se admite un archivo JSON de muestra: `tgi_grafana.json <https://github.com/huggingface/text-generation-inference/blob/main/assets/tgi_grafana.json>`_
5. Visualiza el panel:
Por último, abre el panel en la IU de Grafana y verás diferentes paneles que muestran los datos de las métricas.

Si tomamos el microservicio TGI como ejemplo, puede ver las siguientes métricas:
* Tiempo hasta el primer token
* Latencia de decodificación por token
* Rendimiento (tokens generados/seg)
* Número de tokens por solicitud
* Número de tokens generados por solicitud

También puede monitorear las solicitudes entrantes al microservicio, el tiempo de respuesta por token, etc., en tiempo real.

Resumen y próximos pasos
========================

Por determinar