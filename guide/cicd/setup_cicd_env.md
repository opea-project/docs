# Setup Test Environment for CI/CD
This document outlines the steps to set up a test environment for OPEA CI/CD from scratch. The environment will be used to run tests and ensure code quality before PR merge and Release.

## Install Habana Driver (Gaudi Only)
1. Driver and software installation
https://docs.habana.ai/en/latest/Installation_Guide/Driver_Installation.html
2. Firmware upgrade
https://docs.habana.ai/en/latest/Installation_Guide/Firmware_Upgrade.html


## Install Docker
```shell
    sudo apt update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl enable docker.service
    sudo systemctl daemon-reload
    sudo systemctl start docker
```
### Troubleshooting Docker Installation
1. Issue: E: Unable to locate package docker-compose-plugin  
**solution:** 
```shell
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
```
2. Issue: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.45/containers/json": dial unix /var/run/docker.sock: connect: permission denied   
**solution:**   
```shell
    # option1. 
    sudo usermod -a -G docker xxx  
    # option2. 
    sudo chmod 666 /var/run/docker.sock 
```
3. Issue: ulimit -n setting. [optional]  
**solution:**  
```shell
    cat << EOF | tee /etc/systemd/system/containerd.service.d/override.conf
    [Service]
    LimitNOFILE=infinity
    EOF
    sudo systemctl restart containerd.service
```
4. Issue: control the maximum number of memory mapped areas that a process can have. [optional]   
**solution:**  
```shell
    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    sysctl vm.max_map_count # check 
```

## Install Conda
For e2e test env setup. 
```shell
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
```

## Install K8S 
1. Use kubeadm to setup k8s cluster.
https://github.com/opea-project/docs/blob/main/guide/installation/k8s_install/k8s_install_kubeadm.md
2. Install Habana plugins  (Gaudi Only)
https://docs.habana.ai/en/latest/Installation_Guide/Additional_Installation/Kubernetes_Installation/Intel_Gaudi_Kubernetes_Device_Plugin.html 
### Some Test Code after Installation
```shell
    kubectl get nodes -o wide
    kubectl get pods -A
    kubectl get cs
    kubectl describe node <node_name>
    kubectl describe pod <pod_name>
```
Test for Gaudi: 
```shell
cat <<EOF | tee test.yaml
apiVersion: batch/v1
kind: Job
metadata:
   name: habanalabs-gaudi-demo
spec:
   template:
      spec:
         hostIPC: true
         restartPolicy: OnFailure
         containers:
          - name: habana-ai-base-container
            image: vault.habana.ai/gaudi-docker/1.21.1/ubuntu24.04/habanalabs/pytorch-installer-2.6.0:latest
            workingDir: /root
            command: ["hl-smi"]
            securityContext:
               capabilities:
                  add: ["SYS_NICE"]
            resources:
               limits:
                  habana.ai/gaudi: 1
EOF

kubectl apply -f test.yaml
kubectl delete -f test.yaml
```

## Setup Image Registry for K8S Test
1. Create a docker image registry.
```shell
cat << EOF | tee registry.yaml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
  delete:
    enabled: true
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
EOF

cd /scratch-1 # place to store the images
mkdir local_image_registry && chmod -R 777 local_image_registry
docker run -d -p 5000:5000 --restart=always --name registry -v /home/sdp/workspace/registry.yaml:/etc/docker/registry/config.yml -v /scratch-1/local_image_registry:/var/lib/registry registry:2
```
2. Setup docker registry clean up cron. 
https://github.com/opea-project/Validation/blob/main/tools/image-registry/cleanup.sh
3. Setup connection to the local registry.   

For docker: 
```shell
cat /etc/docker/daemon.json
# gaudi: 
{"runtimes": {"habana": {"path": "/usr/bin/habana-container-runtime", "runtimeArgs": []}}, "default-runtime": "habana", "insecure-registries" : [ "100.83.111.232:5000" ]}
# xeon: 
{"insecure-registries": ["100.83.111.232:5000"]}

# restart docker
sudo systemctl restart docker

# for test
docker pull opea/chatqna:latest
docker tag opea/chatqna:latest 100.83.111.232:5000/opea/chatqna:test
docker push 100.83.111.232:5000/opea/chatqna:test
```
For K8S: 
```shell
# setup in client side
cat /etc/containerd/config.toml
...
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
      endpoint = ["https://registry-1.docker.io"]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."100.83.111.232:5000"]
      endpoint = ["http://100.83.111.232:5000"]
...
# restart containerd
sudo systemctl restart containerd.service

# setup in server side
cd /etc/containerd
sudo mkdir -p certs.d/100.83.111.232:5000 
cd certs.d/100.83.111.232:5000 
cat << EOF | sudo tee hosts.toml
server = "http://100.83.111.232:5000"
[host."http://100.83.111.232:5000"]
  capabilities = ["pull", "resolve", "push"]
EOF

# restart containerd
sudo systemctl restart containerd.service

# for test
docker pull opea/chatqna:latest
docker tag opea/chatqna:latest 100.83.111.232:5000/opea/chatqna:test
docker push 100.83.111.232:5000/opea/chatqna:test
sudo nerdctl -n k8s.io pull 100.83.111.232:5000/opea/chatqna:test
```
4. Setup ENV for CI/CD. 
```shell
vi .bashrc
export OPEA_IMAGE_REPO=100.83.111.232:5000/
```
5. Build and push images to the new local registry.

## Setup GHA ENV for CI/CD
1. Setup self-hosed runner for GHA, follow official steps. 
2. Setup ENV for GHA. 
```shell
vi ~/action_runner/.env
OPEA_IMAGE_REPO=100.83.111.232:5000/
```
3. Start runner with svc. 
```shell
sudo ./svc.sh install # use svc.sh instead of run.sh
sudo ./svc.sh start 
sudo ./svc.sh status 
sudo ./svc.sh stop 
```
## Setup Action Runner Controller (ARC)
https://docs.github.com/en/actions/tutorials/quickstart-for-actions-runner-controller  
For now, we only support use ARC on Xeon K8S cluster.    
1. Install the ARC
Make sure you have installed k8s and helm charts in your test machine.   
```shell
NAMESPACE="opea-arc-systems"
helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

helm uninstall arc -n $NAMESPACE
kubectl delete namespace $NAMESPACE --grace-period=0 --force
```
2. Install a runner scale set
The runner image that we used in CI/CD build by this [dockerfile](https://github.com/opea-project/Validation/blob/main/tools/actions-runner-controller/xeon.dockerfile). 
And the config setting for the runner scale set can be found in [here](https://github.com/opea-project/Validation/blob/main/tools/actions-runner-controller/xeon.yaml).
```shell
RUNNER_SET_NAME="xeon"
RUNNERS_NAMESPACE="opea-runner-set-c1"
RUNNER_GROUP="opea-runner-set-1" # before use this name, make sure this group has been created in GHA. 
GITHUB_CONFIG_URL="https://github.com/opea-project"
GITHUB_PAT="xxx" # the personal access token for GHA, which has the permission to create runners in the repo.
helm install "${RUNNER_SET_NAME}" \
    --namespace "${RUNNERS_NAMESPACE}" \
    --create-namespace \
    -f xeon_large.yaml \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    --set runnerGroup="${RUNNER_GROUP}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```
**Nodes:**   
a. Make sure the nodes in the cluster have enough resources to run the runner pods.   
b. Create the special `RUNNER_GROUP` in GHA, which is used to group the runners.  
c. Make sure you have set up label for `nodeSelector`, with `kubectl label nodes opea-cicd-spr-0 runner-node=true` and use `kubectl get nodes --show-labels` to check the labels.  
d. Make sure you have `/data2` for model cache. 

3. Clean up the ARC (If needed)
```shell
# clean up runner set
(
RUNNER_SET_NAME="xeon"
RUNNERS_NAMESPACE="opea-runner-set-c1"
helm uninstall $RUNNER_SET_NAME -n $RUNNERS_NAMESPACE
kubectl delete namespace $RUNNERS_NAMESPACE --grace-period=0 --force
)
# clean up ARC
(
NAMESPACE="opea-arc-systems"
helm uninstall arc -n $NAMESPACE
kubectl delete namespace $NAMESPACE --grace-period=0 --force
)
```