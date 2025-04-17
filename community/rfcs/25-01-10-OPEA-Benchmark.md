# Purpose

This RFC is used to describe the behavior of unified benchmark script for GenAIExamples user.

In v1.1, those bechmark scripts are per examples. It causes many duplicated codes and bad user experience.  

That is why we have motivation to improve such tool to have an unified entry for perf benchmark.

## Original benchmark script layout

```
GenAIExamples/
├── ChatQnA/
│   ├── benchmark/
│   │   ├── benchmark.sh # each example has its own script
│   │   └── deploy.py
│   ├── kubernetes/
│   │   ├── charts.yaml
│   │   └── ...
│   ├── docker-compose/
│   │   └── compose.yaml
│   └── chatqna.py
└── ...
```

## Proposed benchmark script layout

```
GenAIExamples/
├── deploy_and_benchmark.py # main entry of GenAIExamples 
├── ChatQnA/
│   ├── chatqna.yaml  # default deploy and benchmark config for deploy_and_benchmark.py
│   ├── kubernetes/
│   │   ├── charts.yaml
│   │   └── ...
│   |── docker-compose/
│   |   └── compose.yaml
|   └── chatqna.py
└── ...
```


# Design

The pesudo code of deploy_and_benchmark.py is listed at below for your reference.

```
# deploy_and_benchmark.py
# below is the pesudo code to demostrate its behavior
#
# def main(yaml_file):
#  # extract all deployment combinations from chatqna.yaml deploy section
#  deploy_traverse_list = extract_deploy_cfg(yaml_file)
#  # for example, deploy_traverse_list = [{'node': 2, 'device': gaudi, 'cards_per_node': 8, ...},
#                                         {'node': 4, 'device': gaudi, 'cards_per_node': 8, ...},
#                                         ...]
#
#  benchmark_traverse_list = extract_benchmark_cfg(yaml_file)
#  # for example, benchmark_traverse_list = [{'concurrency': 128, , 'totoal_query_num': 4096, ...},
#                                            {'concurrency': 128, , 'totoal_query_num': 4096, ...},
#                                             ...]
#  for deploy_cfg in deploy_traverse_list:
#    start_k8s_service(deploy_cfg)
#    for benchmark_cfg in benchmark_traverse_list:
#      if service_ready:
#         ingest_dataset(benchmark_cfg.dataset)
#         send_http_request(benchmark_cfg) # will call stresscli.py in GenAIEval 
```

Taking chatqna as an example, the configurable fields are listed at below

```
# chatqna.yaml
#
# usage:
#  1)    deploy_and_benchmark.py --workload chatqna [overrided parameters]
#  2) or deploy_and_benchmark.py ./chatqna/benchmark/chatqna.yaml [overrided parameters]
#
#  for example, deploy_and_benchmark.sh ./chatqna/benchmark/chatqna.yaml --node=2
#
deploy:
   # hardware related config
   device:         [xeon, gaudi, ...] # AMD and other h/ws could be extended into here
   node:           [1, 2, 4]
   cards_per_node: [4, 8]

   # components related config, by default is for OOB, if overrided, then it is for tuned version
   embedding:
      model_id:              bge_large_v1.5
      instance_num:          [2, 4, 8]
      cores_per_instance:    4
      memory_capacity:       20 # unit: G
   retrieval:
      instance_num:       [2, 4, 8]
      cores_per_instance: 4
      memory_capacity:    20 # unit: G
   rerank:
      enable:             True
      model_id:           bge_rerank_v1.5
      instance_num:       1
      cards_per_instance: 1     # if cpu is specified, this field is ignored and will check cores_per_instance field
   llm:
      model_id:           llama2-7b
      instance_num:       7
      cards_per_instance: 1     # if cpu is specified, this field is ignored and will check cores_per_instance field
      # serving related config, dynamic batching
      max_batch_size:     [1, 2, 8, 16, 32]  # the query number to construct a single batch in serving
      max_latency:        20     # time to wait before combining incoming requests into a batch, unit milliseconds

benchmark:
   # http request behavior related fields
   concurrency:               [1, 2, 4]
   totoal_query_num:          [2048, 4096]
   duration:                  [5, 10] # unit minutes
   query_num_per_concurrency: [4, 8, 16]
   possion:                   True
   possion_arrival_rate:      1.0
   warmup_iterations:         10
   seed:                      1024

   # dataset relted fields
   dataset:                [dummy_english, dummy_chinese, pub_med100, ...] # predefined keywords for supported dataset
   user_query:             [dummy_english_qlist, dummy_chinese_qlist, pub_med100_qlist, ...]
   query_token_size:       128                   # if specified, means fixed query token size will be sent out
   data_ratio:             [10%, 20%, ..., 100%] # optional, ratio from query dataset 

   #advance settings in each component which will impact perf.
   data_prep:                  # not target this time
      chunk_size:              [1024]
      chunk_overlap:           [1000]
   retriver:                   # not target this time
      algo:                    IVF
      fetch_k:                 2
      k:                       1
   rerank:
      top_n:                   2
   llm:
      max_token_size:          1024   # specify the output token size
```
