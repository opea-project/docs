# Встановлення з'єднувача мікросервісів GenAI (GMC)

У цьому документі буде представлено коннектор мікросервісів GenAI (GMC) та його встановлення. Потім буде використано трубопровід ChatQnA як приклад використання для демонстрації функціональних можливостей GMC.

## GenAI-мікросервіси-з'єднувач (GMC)

GMC можна використовувати для динамічної компоновки та налаштування трубопроводів GenAI на Kubernetes. Він може використовувати мікросервіси, що надаються GenAIComps, та зовнішні сервіси для складання трубопроводів GenAI. Зовнішні сервіси можуть працювати в публічній хмарі або локально. Просто надайте URL-адресу та деталі доступу, такі як ключ API, і переконайтеся, що є мережеве підключення. Це також дозволяє користувачам налаштовувати трубопровід на льоту, наприклад, перемикатися на іншу велику мовну модель (LLM), додавати нові функції в ланцюжок (наприклад, додавати захисні бар'єри) тощо. GMC підтримує різні типи кроків у трубопроводі, такі як послідовні, паралельні та умовні. Для отримання додаткової інформації:
 https://github.com/opea-project/GenAIInfra/tree/main/microservices-connector

## Встановлення GMC

**Передумови**

- Для прикладу ChatQnA переконайтеся, що у вашому кластері працює кластер Kubernetes з принаймні 16 процесорами, 32 ГБ пам'яті та 100 ГБ дискового простору. Для встановлення кластера Kubernetes див:
[«Встановлення Kubernetes»](../k8s_install/README.md) 

**Завантажте репозиторій GMC на github**

```sh
git clone https://github.com/opea-project/GenAIInfra.git && cd GenAIInfra/microservices-connector
```

**Створіть і перемістіть ваш образ у місце, вказане параметром `CTR_IMG`:**

```sh
make docker.build docker.push CTR_IMG=<some-registry>/gmcmanager:<tag>
```

**Примітка:** Цей образ буде опублікований у вказаному вами особистому реєстрі.
І для того, щоб витягнути образ з робочого середовища, потрібно мати до нього доступ. Переконайтеся, що у вас є відповідні права доступу до реєстру, якщо наведені вище команди не працюють.

**Встановлення GMC CRD**

```sh
kubectl apply -f config/crd/bases/gmc.opea.io_gmconnectors.yaml
```

**Отримайте пов'язані маніфести для компонентів GenAI**

```sh
mkdir -p $(pwd)/config/manifests
cp $(dirname $(pwd))/manifests/ChatQnA/*.yaml -p $(pwd)/config/manifests/
```

**Скопіюйте маніфест роутера GMC**

```sh
cp $(pwd)/config/gmcrouter/gmc-router.yaml -p $(pwd)/config/manifests/
```

**Створіть простір імен для розгортання gmcmanager**

```sh
export SYSTEM_NAMESPACE=system
kubectl create namespace $SYSTEM_NAMESPACE
```

**Примітка:** Будь ласка, використовуйте те саме значення параметра `SYSTEM_NAMESPACE`, яке ви використовували під час розгортання gmc-manager.yaml і gmc-manager-rbac.yaml.

**Створіть ConfigMap для GMC, щоб зберігати маніфести компонентів GenAI та GMC Router**

```sh
kubectl create configmap gmcyaml -n $SYSTEM_NAMESPACE --from-file $(pwd)/config/manifests
```

**Примітка:** Назву конфігураційної карти `gmcyaml` визначено у специфікації розгортання gmcmanager. Будь ласка, внесіть відповідні зміни, якщо ви хочете використовувати іншу назву конфігураційної карти.

**Встановлення GMC manager**

```sh
kubectl apply -f $(pwd)/config/rbac/gmc-manager-rbac.yaml
kubectl apply -f $(pwd)/config/manager/gmc-manager.yaml
```

**Перевірка результату інсталяції**

```sh
kubectl get pods -n system
NAME                              READY   STATUS    RESTARTS   AGE
gmc-controller-78f9c748cb-ltcdv   1/1     Running   0          3m
```

## Використовуйте GMC для створення трубопроводу chatQnA
Зразок для chatQnA можна знайти у файлі config/samples/chatQnA_xeon.yaml

**Розгортання користувацького ресурсу GMC chatQnA**

```sh
kubectl create ns chatqa
kubectl apply -f $(pwd)/config/samples/chatQnA_xeon.yaml
```

**GMC узгодить користувацький ресурс chatQnA і підготує всі пов'язані з ним компоненти/сервіси**

```sh
kubectl get service -n chatqa
```

**Перевірте користувацький ресурс GMC chatQnA, щоб отримати URL-адресу доступу до трубопроводу**

```bash
$kubectl get gmconnectors.gmc.opea.io -n chatqa
NAME     URL                                                      READY     AGE
chatqa   http://router-service.chatqa.svc.cluster.local:8080      8/0/8     3m
```

**Розгорніть один клієнтський модуль для тестування програми chatQnA**

```bash
kubectl create deployment client-test -n chatqa --image=python:3.8.13 -- sleep infinity
```

**Отримайте доступ до трубопроводу за наведеною вище URL-адресою з клієнтського модуля**

```bash
export CLIENT_POD=$(kubectl get pod -n chatqa -l app=client-test -o jsonpath={.items..metadata.name})
export accessUrl=$(kubectl get gmc -n chatqa -o jsonpath="{.items[?(@.metadata.name=='chatqa')].status.accessUrl}")
kubectl exec "$CLIENT_POD" -n chatqa -- curl $accessUrl  -X POST  -d '{"text":"What is the revenue of Nike in 2023?","parameters":{"max_new_tokens":17, "do_sample": true}}' -H 'Content-Type: application/json'
```
