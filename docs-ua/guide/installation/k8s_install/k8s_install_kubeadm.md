# Демонстрація встановлення Kubernetes за допомогою kubeadm

У цій демонстрації ми встановимо Kubernetes v1.29 за допомогою офіційного [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/) на 2-вузловий кластер.

## Конфігурація вузла

| hostname   | ip address         | Operating System |
| ---------- | ------------------ | ---------------- |
| k8s-master | 192.168.121.35/24  | Ubuntu 22.04     |
| k8s-worker | 192.168.121.133/24 | Ubuntu 22.04     |

Ці 2 вузли потребують наступного проксі для доступу до інтернету:

- http_proxy="http://proxy.fake-proxy.com:911"
- https_proxy="http://proxy.fake-proxy.com:912"

Ми припускаємо, що ці 2 вузли правильно налаштовані з відповідними проксі, тому ми можемо отримати доступ до інтернету як в терміналі bash, так і в репозиторії apt.

## Крок 0. Очистіть навколишнє середовище

Якщо на будь-якому з вищевказаних 2 вузлів раніше було встановлено Kubernetes або будь-яке інше контейнерне середовище виконання (наприклад, docker, containerd і т.д.), будь ласка, переконайтеся, що ви їх спочатку видалили.

Якщо на одному з цих вузлів за допомогою `kubeadm` було встановлено попередній Kubernetes, зверніться до перелічених кроків, щоб спочатку [знести Kubernetes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down).
Якщо на одному з цих вузлів за допомогою `kubespray` було встановлено попередню версію Kubernetes, спершу зверніться до kubespray doc, щоб [очистити Kubernetes](https://kubespray.io/#/?id=quick-start).

Після того, як Kubernetes буде зруйновано або очищено, будь ласка, виконайте наступну команду на всіх вузлах, щоб видалити відповідні пакунки:

```bash
sudo apt-get purge docker docker-engine docker.io containerd runc containerd.io kubeadm kubectl kubelet
sudo rm -r /etc/cni /etc/kubernetes /var/lib/kubelet /var/run/kubernetes /etc/containerd /etc/systemd/system/containerd.service.d /etc/default/kubelet
```

## Крок 1. Встановіть відповідні компоненти

Виконайте наступні дії на всіх вузлах:

1. Експортуйте налаштування проксі в bash

```bash
export http_proxy="http://proxy.fake-proxy.com:911"
export https_proxy="http://proxy.fake-proxy.com:912"
# Please make sure you've added all the node's ip addresses into the no_proxy environment variable
export no_proxy="localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,192.168.121.35,192.168.121.133"
```

2. Налаштуйте системні параметри

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

3. Встановіть контейнерний CRI та відповідні компоненти

```bash
# You may change the component version if necessary
CONTAINERD_VER="1.7.18"
RUNC_VER="1.1.12"
CNI_VER="1.5.0"
NERDCTL_VER="1.7.6"
BUILDKIT_VER="0.13.2"

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

4. Встановіть kubeadm і пов'язані компоненти

```bash
# Ви можете змінити версію компонента, якщо це необхідно
K8S_VER="1.29"

#Install kubeadm/kubectl/kubelet
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```

## Крок 2. Створіть кластер k8s

1. (необов'язково) Встановіть helm v3: на вузлі k8s-master виконайте наступні команди:

```bash
#You may skip helm v3 installation if you don't plan to use helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
```

2. Ініціалізуйте вузол площини керування Kubernetes: на вузлі k8s-master виконайте наступні команди:

```bash
POD_CIDR="10.244.0.0/16"
sudo -E kubeadm init --pod-network-cidr "${POD_CIDR}"
```

Після успішного завершення ви побачите вивід kubeadm, подібний до наведеного нижче. Будь ласка, запишіть командний рядок `kubeadm join` для подальшого використання.

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

3. Створіть конфігурацію kubectl для звичайного користувача: на вузлі k8s-master виконайте наступні команди:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# install bash-completion for kubectl
sudo apt-get install -y bash-completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl
```

4. Встановіть Kubernetes CNI Calico: на вузлі k8s-master виконайте наступні команди:

```bash
# Please set correct NODE_CIDR based on your node ip address.
# In this example, because both nodes are in 192.168.121.0/24 subnet,
# we set NODE_CIDR accordingly.
NODE_CIDR="192.168.121.0/24"
# You may change the component version if necessary
CALICO_VER="3.28.0"
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

5. Приєднайтеся до робочих вузлів Kubernetes: на вузлі k8s-worker виконайте наступні команди:
```bash
# run the kubeadm join command which we recorded at the end of the step 2.4
sudo kubeadm join 192.168.121.35:6443 --token 26tg15.km2ru94h9ht9h6ou --discovery-token-ca-cert-hash sha256:123f3f8ebaf62f8dfc4542360e5103842408a6cdf630af159e2abc260201ba99
```

6. На головному вузлі Kubernetes переконайтеся, що всі вузли успішно приєднано:

Запустіть команду `kubectl get pod -A`, щоб переконатися, що всі pod'и перебувають у статусі 'Running'. Якщо якийсь із pod'ів не перебуває у статусі «Виконується», спробуйте виконати наведену вище команду ще раз. Для того, щоб підготувати всі pod'и, може знадобитися кілька хвилин.
Можливий вивід статусу pod може бути приблизно таким

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

Виконайте команду `kubectl get node`, щоб переконатися, що всі вузли перебувають у стані 'Ready'. Можливий вивід має бути приблизно таким:

```
vagrant@k8s-master:~$ kubectl get node
NAME          STATUS   ROLES           AGE     VERSION
k8s-master    Ready    control-plane   31m     v1.29.6
k8s-worker1   Ready    <none>          7m31s   v1.29.6
```

## Крок 3 (необов'язково) Перезавантажте кластер Kubernetes

У деяких випадках вам може знадобитися скинути кластер Kubernetes, якщо деякі команди після `kubeadm init` не вдасться виконати, і ви захочете перевстановити Kubernetes. Будь ласка, зверніться до статті [tear down the Kubernetes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down) для отримання детальної інформації.

Нижче наведено приклад того, як скинути щойно створений кластер Kubernetes:

На вузлі k8s-master виконайте наступну команду:

```bash
# drain node k8s-worker1
kubectl drain k8s-worker1 --delete-emptydir-data --force --ignore-daemonsets
```

На вузлі k8s-worker1 виконайте наступну команду:

```bash
sudo kubeadm reset
# manually reset iptables/ipvs if necessary
```

На вузлі k8s-master видаліть вузол k8s-worker1:

```bash
kubectl delete node k8s-worker1
```

На вузлі k8s-master очистіть головний вузол:

```bash
sudo kubeadm reset
# manually reset iptables/ipvs if necessary
```

## Примітки

1. За замовчуванням, нормальне навантаження не планується для вузлів у ролі K8S `control-plane` (тобто для головного вузла K8S). Якщо ви хочете, щоб K8S планував нормальне навантаження на ці вузли, будь ласка, виконайте наступні команди на головному вузлі K8S:

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl label nodes --all node.kubernetes.io/exclude-from-external-load-balancers-
```

2. Верифікація K8S CNI

   Якщо у вас виникли проблеми з міжвузловим зв'язком, будь ласка, виконайте наступні кроки, щоб переконатися, що k8s CNI працює належним чином:

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

Зачекайте, доки всі 2 налагоджувальні модулі не перейдуть у стан «Виконується»:

```
vagrant@k8s-master:~$ kubectl get pod -owide
NAME                    READY   STATUS    RESTARTS   AGE   IP               NODE          NOMINATED NODE   READINESS GATES
debug-ddfd698ff-7gsdc   1/1     Running   0          91s   10.244.194.66    k8s-worker1   <none>           <none>
debug-ddfd698ff-z5qpv   1/1     Running   0          91s   10.244.235.199   k8s-master    <none>           <none>
```

Переконайтеся, що pod `debug-ddfd698ff-z5qpv` на вузлі k8s-master може пінгувати ip-адресу іншого pod `debug-ddfd698ff-7gsdc` на вузлі k8s-worker1, щоб перевірити роботу трафіку зі сходу на захід у K8S.

```
vagrant@k8s-master:~$ kubectl exec debug-ddfd698ff-z5qpv -- ping -c 1 10.244.194.66
PING 10.244.194.66 (10.244.194.66) 56(84) bytes of data.
64 bytes from 10.244.194.66: icmp_seq=1 ttl=62 time=1.76 ms

--- 10.244.194.66 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.755/1.755/1.755/0.000 ms
```

Переконайтеся, що pod `debug-ddfd698ff-z5qpv` на вузлі k8s-master може пінгувати ip-адресу іншого вузла `k8s-worker1`, щоб перевірити, чи працює трафік північ-південь у K8S.

```
vagrant@k8s-master:~$ kubectl exec debug-ddfd698ff-z5qpv -- ping -c 1 192.168.121.133
PING 192.168.121.133 (192.168.121.133) 56(84) bytes of data.
64 bytes from 192.168.121.133: icmp_seq=1 ttl=63 time=1.34 ms

--- 192.168.121.133 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.339/1.339/1.339/0.000 ms
```

Видаліть налагоджувальні pod'и після використання:

```bash
kubectl delete -f debug.yaml
```
