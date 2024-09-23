
# Monitoring ChatQnA deployment

Now that you have deployed the ChatQnA example, let's talk about monitoring the performance of the microservices in the ChatQnA pipeline.

Monitoring the performance of microservices is crucial for ensuring the smooth operation of the generative AI systems. By monitoring metrics such as latency and throughput, you can identify bottlenecks, detect anomalies, and optimize the performance of individual microservices. This allows us to proactively address any issues and ensure that the ChatQnA pipeline is running efficiently.

This document will help you understand how to monitor in real time the latency, throughput, and other metrics of different microservices. You will use **Prometheus** and **Grafana**, both open-source toolkits, to collect metrics and visualize them in a dashboard.

### Set up the Prometheus server

Prometheus is a tool used for recording real-time metrics and is specifically designed for monitoring microservices and alerting based on their metrics.

The `/metrics` endpoint on the port running each microservice exposes the metrics in the Prometheus format. The Prometheus server scrapes these metrics and stores them in its time series database. For example, metrics for the Text Generation Interface (TGI) service are available at:
```bash
http://${host_ip}:9009/metrics 
```

To set up the Prometheus server, follow these steps:

#### 1. Download Prometheus:
Download the Prometheus v2.52.0 from the official youbsite, and extract the files:
```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar -xvzf prometheus-2.52.0.linux-amd64.tar.gz
```

#### 2. Configure Prometheus:
Change the directory to the Prometheus folder:
```bash
cd prometheus-2.52.0.linux-amd64
```
Edit the `prometheus.yml` file:
```
vim prometheus.yml
```
Change the `job_name` to the name of the microservice you want to monitor. Also change the `targets` to the job target endpoint of that microservice. Make sure the service is running and the port is open, and that it exposes the metrics that follow Prometheus convention at the `/metrics` endpoint.

Here is an example of exporting metrics data from a TGI microservice to Prometheus:
```yaml
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "tgi"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9009"]
```
Here is another example of exporting metrics data from a TGI microservice (inside a Kubernetes cluster) to Prometheus:
```yaml
scrape_configs:
  - job_name: "tgi"

    static_configs:
      - targets: ["llm-dependency-svc.default.svc.cluster.local:9009"]
```

#### 3. Run the Prometheus server:
Run the Prometheus server, without hanging-up the process:
```bash
nohup ./prometheus --config.file=./prometheus.yml &
```

#### 4. Access the Prometheus UI
Access the Prometheus UI at the following URL:
```bash
http://localhost:9090/targets?search=
```
>Note: Before starting Prometheus, ensure that no other processes are running on the designated port (default is 9090). Otherwise, Prometheus will not be able to scrape the metrics.

On the Prometheus UI, you can see the status of the targets and the metrics that are being scraped. You can search for a metrics variable by typing it in the search bar.

The TGI metrics can be accessed at:
```bash
http://${host_ip}:9009/metrics 
```

### Set up the Grafana dashboard
Grafana is a tool used for visualizing metrics and creating dashboards. It can be used to create custom dashboards that display the metrics collected by Prometheus.

To set up the Grafana dashboard, follow these steps:
#### 1. Download Grafana:
Download the Grafana v8.0.6 from the official youbsite, and extract the files:
```bash
wget https://dl.grafana.com/oss/release/grafana-11.0.0.linux-amd64.tar.gz
tar -zxvf grafana-11.0.0.linux-amd64.tar.gz
```
If you have any Grafana installation issue please check this [link](https://grafana.com/docs/grafana/latest/setup-grafana/installation/).

#### 2. Run the Grafana server:
Change the directory to the Grafana folder:
```bash
cd grafana-11.0.0
```
Run the Grafana server, without hanging-up the process:
```bash
nohup ./bin/grafana-server &
```

#### 3. Access the Grafana dashboard UI:
On your browser, access the Grafana dashboard UI at the following URL:
```bash
http://localhost:3000
```
>Note: Before starting Grafana, ensure that no other processes are running on port 3000.

Log in to Grafana using the default credentials:
```
username: admin
password: admin
```

#### 4. Add Prometheus as a data source:
You need to configure the data source for Grafana to scrape data from. Click on the "Data Source" button, select Prometheus, and specify the Prometheus URL `http://localhost:9090`.

Then, you need to upload a JSON file for the dashboard's configuration. You can upload it in the Grafana UI under `Home > Dashboards > Import dashboard`. A sample JSON file is supported here: [tgi_grafana.json](https://github.com/huggingface/text-generation-inference/blob/main/assets/tgi_grafana.json)

#### 5. View the dashboard:
Finally, open the dashboard in the Grafana UI, and you will see different panels displaying the metrics data.

Taking the TGI microservice as an example, you can see the following metrics:
- Time to first token
- Decode per-token latency
- Throughput (generated tokens/sec)
- Number of tokens per prompt
- Number of generated tokens per request

You can also monitor the incoming requests to the microservice, the response time per token, etc., in real time.

