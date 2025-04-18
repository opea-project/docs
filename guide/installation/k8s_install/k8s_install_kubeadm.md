# Kubernetes installation demo using kubeadm

In this demo, we'll install Kubernetes v1.32 using official [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/) on a 2 node cluster.

## Node configuration

| hostname   | ip address         | Operating System |
| ---------- | ------------------ | ---------------- |
| k8s-master | 192.168.121.35/24  | Ubuntu 22.04     |
| k8s-worker | 192.168.121.133/24 | Ubuntu 22.04     |

These 2 nodes needs the following proxy to access the internet:

- http_proxy="http://proxy.fake-proxy.com:911"
- https_proxy="http://proxy.fake-proxy.com:912"

We assume these 2 nodes have been set correctly with the corresponding proxy so we can access the internet both in bash terminal and in apt repository.

## Step 0. Clean up the environment

If on any of the above 2 nodes, you have previously installed either Kubernetes, or any other container runtime(i.e. docker, containerd, etc.), please make sure you have clean-up those first.

If there is any previous Kubernetes installed on any of these nodes by `kubeadm`, please refer to the listed steps to [tear down the Kubernetes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down) first.

If there is any previous Kubernetes installed on any of these nodes by `kubespray`, please refer to kubespray doc to [clean up the Kubernetes](https://kubespray.io/#/?id=quick-start) first.

Once the Kubernetes is teared down or cleaned up, please run the following command on all the nodes to remove relevant packages:

```bash
sudo apt-get purge docker docker-engine docker.io containerd runc containerd.io kubeadm kubectl kubelet
sudo rm -r /etc/cni /etc/kubernetes /var/lib/kubelet /var/run/kubernetes /etc/containerd /etc/systemd/system/containerd.service.d /etc/default/kubelet
```

## Step 1. Install relevant components

Run the following on all the nodes:

1. Export proxy settings in bash

```bash
export http_proxy="http://proxy.fake-proxy.com:911"
export https_proxy="http://proxy.fake-proxy.com:912"
# Please make sure you've added all the node's ip addresses into the no_proxy environment variable
export no_proxy="localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,192.168.121.35,192.168.121.133"
```

2. Config system settings

```bash
# Disable swap
sudo swapoff -a
sudo sed -i "s/^\(.* swap \)/#\1/g" /etc/fstab
# load kernel module for containerd
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
# Enable IPv4 packet forwarding
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
```

3. Install containerd CRI and relevant components

```bash
# You may change the component version if necessary
CONTAINERD_VER="1.7.27"
RUNC_VER="1.2.5"
CNI_VER="1.6.2"
NERDCTL_VER="2.0.4"
BUILDKIT_VER="0.20.0"

#Install Runc
wget https://github.com/opencontainers/runc/releases/download/v${RUNC_VER}/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
rm -f runc.amd64

#Install CNI
sudo mkdir -p /opt/cni/bin
wget -c https://github.com/containernetworking/plugins/releases/download/v${CNI_VER}/cni-plugins-linux-amd64-v${CNI_VER}.tgz -qO - | sudo tar xvz -C /opt/cni/bin

#Install Containerd
wget -c https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VER}/containerd-${CONTAINERD_VER}-linux-amd64.tar.gz -qO - | sudo tar xvz -C /usr/local
sudo mkdir -p /usr/local/lib/systemd/system/containerd.service.d
sudo -E wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -qO /usr/local/lib/systemd/system/containerd.service
cat <<EOF | sudo tee /usr/local/lib/systemd/system/containerd.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${https_proxy}"
Environment="NO_PROXY=${no_proxy}"
EOF
sudo mkdir -p /etc/containerd
sudo rm -f /etc/containerd/config.toml
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl restart containerd

#Install nerdctl
wget -c https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VER}/nerdctl-${NERDCTL_VER}-linux-amd64.tar.gz -qO - | sudo tar xvz -C /usr/local/bin

#You may skip buildkit installation if you don't need to build container images.
#Install buildkit
wget -c https://github.com/moby/buildkit/releases/download/v${BUILDKIT_VER}/buildkit-v${BUILDKIT_VER}.linux-amd64.tar.gz -qO - | sudo tar xvz -C /usr/local
sudo mkdir -p /etc/buildkit
cat <<EOF | sudo tee /etc/buildkit/buildkitd.toml
[worker.oci]
  enabled = false
[worker.containerd]
  enabled = true
  # namespace should be "k8s.io" for Kubernetes (including Rancher Desktop)
  namespace = "default"
EOF
sudo mkdir -p /usr/local/lib/systemd/system/buildkit.service.d
cat <<EOF | sudo tee /usr/local/lib/systemd/system/buildkit.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${https_proxy}"
Environment="NO_PROXY=${no_proxy}"
EOF
sudo -E wget https://raw.githubusercontent.com/moby/buildkit/v${BUILDKIT_VER}/examples/systemd/system/buildkit.service -qO /usr/local/lib/systemd/system/buildkit.service
sudo -E wget https://raw.githubusercontent.com/moby/buildkit/v${BUILDKIT_VER}/examples/systemd/system/buildkit.socket -qO /usr/local/lib/systemd/system/buildkit.socket
sudo systemctl daemon-reload
sudo systemctl enable --now buildkit
sudo systemctl restart buildkit
```

4. Install kubeadm and related components

```bash
# You may change the component version if necessary
K8S_VER="1.32"

#Install kubeadm/kubectl/kubelet
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```

## Step 2. Create the k8s cluster

1. (optional) Install helm v3: on node k8s-master, run the following commands:

```bash
#You may skip helm v3 installation if you don't plan to use helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
```

2. Initialize the Kubernetes control-plane node: on node k8s-master, run the following commands:

```bash
export POD_CIDR="10.244.0.0/16"
sudo -E kubeadm init --pod-network-cidr "${POD_CIDR}"
```

Once succeed, you'll find the kubeadm's output such as the following. Please record the `kubeadm join` command line for later use.

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

 mkdir -p $HOME/.kube
 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

 export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
 https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.121.35:6443 --token 26tg15.km2ru94h9ht9h6ou \
       --discovery-token-ca-cert-hash sha256:123f3f8ebaf62f8dfc4542360e5103842408a6cdf630af159e2abc260201ba99
```

3. Create kubectl configuration for a regular user: on node k8s-master, run the following commands:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# install bash-completion for kubectl
sudo apt-get install -y bash-completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
```

4. Install Kubernetes CNI Calico: on node k8s-master, run the following commands:

```bash
# Please set correct NODE_CIDR based on your node ip address.
# In this example, because both nodes are in 192.168.121.0/24 subnet,
# we set NODE_CIDR accordingly.
NODE_CIDR="192.168.121.0/24"
# You may change the component version if necessary
CALICO_VER="3.29.3"
kubectl create -f "https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VER}/manifests/tigera-operator.yaml"
sleep 10
cat <<EOF | kubectl create -f -
# This section includes base Calico installation configuration.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: ${POD_CIDR}
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      cidrs: ["${NODE_CIDR}"]
---
# This section configures the Calico API server.
# For more information, see: https://docs.tigera.io/calico/latest/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF
```

5. Join Kubernetes worker nodes: on node k8s-worker, run the following commands:

```bash
# run the kubeadm join command which we recorded at the end of the step 2.4
sudo kubeadm join 192.168.121.35:6443 --token 26tg15.km2ru94h9ht9h6ou --discovery-token-ca-cert-hash sha256:123f3f8ebaf62f8dfc4542360e5103842408a6cdf630af159e2abc260201ba99
```

6. On Kubernetes master node, verify that all nodes are joined successfully:

Run command `kubectl get pod -A` to make sure all pods are in 'Running' status. If any of the pods are not in 'Running' status, please retry the above command. It could take up to several minutes for all the pods to be ready.

Possible output of pod status could be something like

```
vagrant@k8s-master:~$ kubectl get pod -A
NAMESPACE          NAME                                       READY   STATUS    RESTARTS   AGE
calico-apiserver   calico-apiserver-59c8dc5bff-ff9vs          1/1     Running   0          3m15s
calico-apiserver   calico-apiserver-59c8dc5bff-zblxr          1/1     Running   0          3m15s
calico-system      calico-kube-controllers-596b8f9f7d-68nnp   1/1     Running   0          5m19s
calico-system      calico-node-gcng6                          1/1     Running   0          5m20s
calico-system      calico-node-xlwsb                          1/1     Running   0          2m7s
calico-system      calico-typha-65f5745579-l29v8              1/1     Running   0          5m20s
calico-system      csi-node-driver-q5gmm                      2/2     Running   0          2m7s
calico-system      csi-node-driver-xrhw5                      2/2     Running   0          5m19s
kube-system        coredns-76f75df574-5z57n                   1/1     Running   0          25m
kube-system        coredns-76f75df574-88pkk                   1/1     Running   0          25m
kube-system        etcd-k8s-master                            1/1     Running   0          25m
kube-system        kube-apiserver-k8s-master                  1/1     Running   0          25m
kube-system        kube-controller-manager-k8s-master         1/1     Running   0          25m
kube-system        kube-proxy-jbd6r                           1/1     Running   0          2m7s
kube-system        kube-proxy-lrgb6                           1/1     Running   0          25m
kube-system        kube-scheduler-k8s-master                  1/1     Running   0          25m
tigera-operator    tigera-operator-76c4974c85-lx79h           1/1     Running   0          10m
```

Run command `kubectl get node` to make sure all node are in 'Ready' status. Possible output should be something like:

```
vagrant@k8s-master:~$ kubectl get node -owide
NAME          STATUS   ROLES           AGE     VERSION   INTERNAL-IP       EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k8s-master    Ready    control-plane   16m     v1.32.3   192.168.121.35    <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.7.27
k8s-worker1   Ready    <none>          5m39s   v1.32.3   192.168.121.133   <none>        Ubuntu 22.04.1 LTS   5.15.0-46-generic   containerd://1.7.27
```

## Step 3 (optional) Reset Kubernetes cluster

In some cases, you may want to reset the Kubernetes cluster in case some commands after `kubeadm init` fail and you want to reinstall Kubernetes. Please check [tear down the Kubernetes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down) for details.

Below is the example of how to reset the Kubernetes cluster we just created:

On node k8s-master, run the following command:

```bash
# drain node k8s-worker1
kubectl drain k8s-worker1 --delete-emptydir-data --force --ignore-daemonsets
```

On node k8s-worker1, run the following command:

```bash
sudo kubeadm reset
# manually reset iptables/ipvs if necessary
```

On node k8s-master, delete node k8s-worker1:

```bash
kubectl delete node k8s-worker1
```

On node k8s-master, clean up the master node:

```bash
sudo kubeadm reset
# manually reset iptables/ipvs if necessary
```

## NOTES

1. By default, normal workload won't be scheduled to nodes in `control-plane` K8S role(i.e. K8S master node). If you want K8S to schedule normal workload to those nodes, please run the following commands on K8S master node:

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl label nodes --all node.kubernetes.io/exclude-from-external-load-balancers-
```

2. Verifying K8S CNI
   If you see any issues of the inter-node pod-to-pod communication, please use the following steps to verify that k8s CNI is working correctly:

```bash
# Create the K8S manifest file for our debug pods
cat <<EOF | tee debug.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: debug
  name: debug
spec:
  replicas: 2
  selector:
    matchLabels:
      run: debug
  template:
    metadata:
      labels:
        run: debug
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: run
                operator: In
                values:
                - debug
            topologyKey: kubernetes.io/hostname
      containers:
      - image: nicolaka/netshoot:latest
        name: debug
        command: [ "sleep", "infinity" ]
EOF
# Create the debug pod
kubectl apply -f debug.yaml
```

Wait until all 2 debug pods are in 'Running' status:

```
vagrant@k8s-master:~$ kubectl get pod -owide
NAME                    READY   STATUS    RESTARTS   AGE   IP               NODE          NOMINATED NODE   READINESS GATES
debug-ddfd698ff-7gsdc   1/1     Running   0          91s   10.244.194.66    k8s-worker1   <none>           <none>
debug-ddfd698ff-z5qpv   1/1     Running   0          91s   10.244.235.199   k8s-master    <none>           <none>
```

Make sure pod `debug-ddfd698ff-z5qpv` on node k8s-master can ping to the ip address of another pod `debug-ddfd698ff-7gsdc` on node k8s-worker1 to verify east-west traffic is working in K8S.

```
vagrant@k8s-master:~$ kubectl exec debug-ddfd698ff-z5qpv -- ping -c 1 10.244.194.66
PING 10.244.194.66 (10.244.194.66) 56(84) bytes of data.
64 bytes from 10.244.194.66: icmp_seq=1 ttl=62 time=1.76 ms

--- 10.244.194.66 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.755/1.755/1.755/0.000 ms
```

Make sure pod `debug-ddfd698ff-z5qpv` on node k8s-master can ping to the ip address of another node `k8s-worker1` to verify north-south traffic is working in K8S.

```
vagrant@k8s-master:~$ kubectl exec debug-ddfd698ff-z5qpv -- ping -c 1 192.168.121.133
PING 192.168.121.133 (192.168.121.133) 56(84) bytes of data.
64 bytes from 192.168.121.133: icmp_seq=1 ttl=63 time=1.34 ms

--- 192.168.121.133 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.339/1.339/1.339/0.000 ms
```

Delete debug pods after use:

```bash
kubectl delete -f debug.yaml
```
