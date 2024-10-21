# Встановлення Kubernetes за допомогою Kubespray

У цьому документі ми встановимо Kubernetes v1.29 за допомогою [Kubespray](https://github.com/kubernetes-sigs/kubespray) на 2-вузловий кластер.

Існує декілька способів використання Kubespray для розгортання кластера Kubernetes. У цьому документі ми обираємо спосіб Ansible. Інші способи використання Kubespary наведено у [документі Kubespray](https://github.com/kubernetes-sigs/kubespray).

## Підготовка вузла

| hostname   | ip address         | Operating System |
| ---------- | ------------------ | ---------------- |
| k8s-master | 192.168.121.35/24  | Ubuntu 22.04     |
| k8s-worker | 192.168.121.133/24 | Ubuntu 22.04     |

 Ми припускаємо, що ці дві машини використовуються для 2-вузлового кластера Kubernetes. Вони мають прямий доступ до інтернету як у терміналі bash, так і в репозиторії apt.

 Якщо на будь-якому з вищевказаних 2 вузлів раніше було встановлено або Kubernetes, або будь-яке інше середовище виконання контейнерів (наприклад, docker, containerd тощо), будь ласка, переконайтеся, що ви очистили їх спочатку. Зверніться до [Демонстрація встановлення Kubernetes за допомогою kubeadm](./k8s_install_kubeadm.md), щоб очистити середовище.

## Передумови

 Ми припускаємо, що існує третя машина, яка є вашою робочою машиною. Ви можете увійти на цю машину і виконати команду Ansible. Будь-який з двох вищезгаданих вузлів K8s може бути використаний як робоча машина. Якщо не вказано інше, всі наступні операції виконуються на робочій машині.

Будь ласка, переконайтеся, що робоча машина може увійти до обох вузлів K8s через SSH без запиту пароля. Існують різні способи налаштувати вхід по ssh без запиту пароля. Простий спосіб - скопіювати відкритий ключ робочої машини на вузли K8s. Наприклад:

```
# generate key pair in the operation machine
ssh-keygen -t rsa -b 4096
# manually copy the public key to the K8s master and worker nodes
cat ~/.ssh/id_rsa.pub | ssh username@k8s-master "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | ssh username@k8s-worker "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

## Крок 1. Налаштуйте Kubespray та Ansible

На цьому кроці потрібен Python3 (версія >= 3.10). Якщо у вас його немає, перейдіть на [веб-сайт Python](https://docs.python.org/3/using/index.html) для отримання інструкції з встановлення.

Вам потрібно створити віртуальне середовище Python і встановити Ansible та інші залежності Kubespray. Для цього ви можете просто виконати наступні команди. Ви також можете звернутися до [Посібника з встановлення Kubespray Ansible](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible/ansible.md#installing-ansible) для отримання детальної інформації. Щоб отримати код kubespray, зверніться до [останньої версії](https://github.com/kubernetes-sigs/kubespray/releases) тегу kubespray. Тут ми використовуємо kubespary v2.25.0 як приклад.

```
git clone https://github.com/kubernetes-sigs/kubespray.git
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
# Check out the latest release version tag of kubespray.
git checkout v2.25.0
pip install -U -r requirements.txt
```

## Крок 2. Створіть власний інвенторій

Інвентаризація Ansible визначає хости і групи хостів, на яких будуть виконуватися завдання Ansible. Ви можете скопіювати зразок інвентаризації за допомогою наступної команди:

```
cp -r inventory/sample inventory/mycluster
```

Відредагуйте файл інвентаризації `inventory/mycluster/inventory.ini`, щоб налаштувати ім'я та IP-адресу вузла. Файл інвентаризації, який використовується у цій демонстрації, наведено нижче:
```
[all]
k8s-master ansible_host=192.168.121.35
k8s-worker ansible_host=192.168.121.133

[kube_control_plane]
k8s-master

[etcd]
k8s-master

[kube_node]
k8s-master
k8s-worker

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
```
## Крок 3. Визначте конфігурацію Kubernetes

Kubespray дає вам можливість налаштувати інсталяцію Kubernetes, наприклад, визначити:
- мережевий плагін
- менеджер контейнерів
- kube_apiserver_port
- kube_pods_subnet
- всі конфігурації аддонів K&s, або навіть визначити розгортання кластера на гіперскейлері, такому як AWS або GCP.

Всі ці налаштування зберігаються у групових змінних, визначених у `inventory/mycluster/group_vars`.

Налаштування K&s дивіться у файлі `inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml`.

**_Примітка:_** Якщо ви помітили проблеми з `TASK [kubernetes/control-plane : Kubeadm | Initialize first master]` у розгортанні K&, змініть порт, на якому буде слухатися сервер API, з 6443 на 8080. За замовчуванням Kubespray налаштовує хости kube_control_plane з незахищеним доступом до kube-apiserver через порт 8080. Зверніться до [kubespray getting-started](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting_started/getting-started.md)

```
# The port the API Server will be listening on.
kube_apiserver_ip: "{{ kube_service_addresses | ansible.utils.ipaddr('net') | ansible.utils.ipaddr(1) | ansible.utils.ipaddr('address') }}"
kube_apiserver_port: 8080  # (http)
```

## Крок 4. Розгортаємо Kubernetes

Ви можете очистити старий кластер Kubernetes за допомогою плейбука Ansible виконуючи наступні команди:
```
# Clean up old Kubernetes cluster with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example cleaning up SSL keys in /etc/,
# uninstalling old packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
# And be mindful that it will remove the current Kubernetes cluster (if it's running)!
ansible-playbook -i inventory/mycluster/inventory.ini  --become --become-user=root -e override_system_hostname=false reset.yml
```

Після цього ви можете розгорнути Kubernetes з плейбуком Ansible за допомогою наступної команди:

```
# Deploy Kubespray with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
ansible-playbook -i inventory/mycluster/inventory.ini  --become --become-user=root -e override_system_hostname=false cluster.yml
```

Виконання плейбуків Ansible займе кілька хвилин. Після того, як плейбук буде виконано, ви можете перевірити вивід. Якщо існує `failed=0`, це означає, що виконання плейбука успішно завершено.

## Крок 5. Створіть конфігурацію kubectl

Якщо ви хочете скористатися інструментом командного рядка Kubernetes `kubectl` на вузлі **k8s-master**, будь ласка, увійдіть на вузол **k8s-master** і виконайте наступні команди:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Якщо ви хочете отримати доступ до цього кластера Kubernetes з інших машин, ви можете встановити kubectl командою sudo apt-get install -y kubectl` і скопіювати конфігурацію з вузла k8-master та встановити права власності, як описано вище.

Потім виконайте наступну команду, щоб перевірити стан вашого кластера Kubernetes:
```
$ kubectl get node
NAME          STATUS   ROLES           AGE     VERSION
k8s-master    Ready    control-plane   31m     v1.29.5
k8s-worker   Ready    <none>          7m31s   v1.29.5
$ kubectl get pods -A
NAMESPACE                    NAME                                       READY   STATUS    RESTARTS   AGE
kube-system                  calico-kube-controllers-68485cbf9c-vwqqj   1/1     Running   0          23m
kube-system                  calico-node-fxr6v                          1/1     Running   0          24m
kube-system                  calico-node-v95sp                          1/1     Running   0          23m
kube-system                  coredns-69db55dd76-ctld7                   1/1     Running   0          23m
kube-system                  coredns-69db55dd76-ztwfg                   1/1     Running   0          23m
kube-system                  dns-autoscaler-6d5984c657-xbwtc            1/1     Running   0          23m
kube-system                  kube-apiserver-satg-opea-0                 1/1     Running   0          24m
kube-system                  kube-controller-manager-satg-opea-0        1/1     Running   0          24m
kube-system                  kube-proxy-8zmhk                           1/1     Running   0          23m
kube-system                  kube-proxy-hbq78                           1/1     Running   0          23m
kube-system                  kube-scheduler-satg-opea-0                 1/1     Running   0          24m
kube-system                  nginx-proxy-satg-opea-3                    1/1     Running   0          23m
kube-system                  nodelocaldns-kbcnv                         1/1     Running   0          23m
kube-system                  nodelocaldns-wvktt                         1/1     Running   0          24m
```
А тепер вітаємо. Ваш двовузловий кластер K8s готовий до роботи.

## Коротка довідка

### Як розгорнути один вузол Kubernetes?

Розгортання одновузлового кластера K8s дуже схоже на розгортання багатовузлового (>=2) кластера K8s.

Дотримуйтесь попереднього [Крок 1. Налаштування Kubespray і Ansible](#step-1-set-up-kubespray-and-ansible), щоб налаштувати середовище.

А потім у [Крок 2. Створіть власний інвенторій] (#step-2-build-your-own-inventory) ви можете створити одновузловий інвенторій Ansible, скопіювавши зразок одновузлового інвенторію, як показано нижче:

```
cp -r inventory/local inventory/mycluster
```

Відредагуйте інвентарний файл `inventory/mycluster/hosts.ini` для одного вузла, замінивши назву вузла з `node1` на вашу справжню назву (наприклад, `k8s-master`) за допомогою наступної команди:

```
sed -i "s/node1/k8s-master/g" inventory/mycluster/hosts.ini
```

Тоді ваш одновузловий інвенторій буде виглядати так, як показано нижче:

```
k8s-master ansible_connection=local local_release_dir={{ansible_env.HOME}}/releases

[kube_control_plane]
k8s-master

[etcd]
k8s-master

[kube_node]
k8s-master

[k8s_cluster:children]
kube_node
kube_control_plane
```

А потім виконайте [Крок 3. Розгортання Kubernetes](#step-3-deploy-kubernetes), будь ласка, зверніть увагу на **inventory name** під час виконання Ansible playbook, а саме `inventory/mycluster/hosts.ini` в одновузловому розгортанні. Після успішного виконання плейбука ви отримаєте готовий 1-вузловий K8s.

І виконайте наступний [Крок 4. Створення конфігурації kubectl](#step-4-create-kubectl-configuration), щоб налаштувати `kubectl`. Ви можете перевірити стан за допомогою `kubectl get nodes`.

### Як масштабувати кластер Kubernetes, щоб додати більше вузлів?

Припустимо, у вас вже є двовузловий кластер K8s і ви хочете масштабувати його до трьох вузлів. Інформація про третій вузол наступна:

| hostname   | ip address         | Operating System |
| ---------- | ------------------ | ---------------- |
| third-node | 192.168.121.134/24  | Ubuntu 22.04     |

Переконайтеся, що третій вузол має доступ до Інтернету і може увійти в систему за допомогою `SSH` без введення пароля з вашого робочого комп'ютера.

Відредагуйте файл інвентаризації Ansible, щоб додати інформацію про третій вузол до розділів `[all]` та `[kube_node]` наступним чином:
```
[all]
k8s-master ansible_host=192.168.121.35
k8s-worker ansible_host=192.168.121.133
third-node ansible_host=192.168.121.134

[kube_control_plane]
k8s-master

[etcd]
k8s-master

[kube_node]
k8s-master
k8s-worker
third-node

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr
```

Потім ви можете розгорнути Kubernetes на третьому вузлі за допомогою плейбука Ansible за допомогою наступної команди:

```
# Deploy Kubespray with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
ansible-playbook -i inventory/mycluster/inventory.ini --limit third-node --become --become-user=root scale.yml -b -v
```
Після успішного виконання плейбуку ви можете перевірити готовність третього вузла за допомогою наступної команди:
```
kubectl get nodes
```

Для отримання додаткової інформації про додавання/видалення вузла Kubernetes ви можете відвідати [Документ Kubespray](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/operations/nodes.md#addingreplacing-a-worker-node).

### Як налаштувати проксі-сервер?

Якщо вашим вузлам потрібен проксі для доступу до інтернету, вам знадобляться додаткові конфігурації під час розгортання K8. 

Ми припускаємо, що ваш проксі виглядає наступним чином:
```
- http_proxy="http://proxy.fake-proxy.com:911"
- https_proxy="http://proxy.fake-proxy.com:912"
```

Ви можете змінити параметри у файлі `inventory/mycluster/group_vars/all/all.yml`, щоб встановити `http_proxy`, `https_proxy` та `additional_no_proxy` наступним чином. Будь ласка, переконайтеся, що ви додали ip-адреси всіх вузлів у параметр `additional_no_proxy`. У цьому прикладі ми використовуємо `192.168.121.0/24` для представлення всіх IP-адрес вузлів.

```
## Set these proxy values in order to update package manager and docker daemon to use proxies and custom CA for https_proxy if needed
http_proxy: "http://proxy.fake-proxy.com:911"
https_proxy: "http://proxy.fake-proxy.com:912"

## If you need exclude all cluster nodes from proxy and other resources, add other resources here.
additional_no_proxy: "localhost,127.0.0.1,192.168.121.0/24"
```
