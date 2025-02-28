# Встановлення Kubernetes за допомогою кластера AWS EKS

У цьому документі ми встановимо Kubernetes v1.30 за допомогою [AWS EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html).

Створити новий кластер Kubernetes з вузлами в AWS EKS можна двома способами:
- ["eksctl"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
- ["AWS Management Console and AWS CLI"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html).

У цьому документі ми представимо метод «Консоль управління AWS і AWS CLI».

## Передумови

Перш ніж розпочати цей посібник, ви повинні встановити і налаштувати наступні інструменти іресурси, необхідні для створення й управління кластером Amazon EKS.

- AWS CLI – Інструмент командного рядка для роботи з сервісами AWS, включаючи Amazon EKS. Для отримання додаткової інформації див. ["Installing, updating, and uninstalling the AWS CLI"](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) в Посібнику користувача інтерфейсу командного рядка AWS. Після встановлення AWS CLI рекомендуємо також налаштувати його. Для отримання додаткової інформації див. ["Quick configuration with aws configure"](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-configure-quickstart-config) у Посібнику користувача інтерфейсу командного рядка AWS.

- kubectl – Інструмент командного рядка для роботи з кластерами Kubernetes. Для отримання додаткової інформації див. ["Installing or updating kubectl"](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html).
- Необхідні дозволи IAM - Принцип безпеки IAM, який ви використовуєте, повинен мати дозволи для роботи з ролями Amazon EKS IAM, ролями, пов'язаними зі службами, AWS CloudFormation, VPC і пов'язаними з ними ресурсами. Для отримання додаткової інформації див. ["Actions, resources, and condition keys for Amazon Elastic Kubernetes Service"](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonelastickubernetesservice.html) і ["Using service-linked roles"](https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html) у Посібнику користувача IAM. Ви повинні виконати всі кроки в цьому посібнику як той самий користувач. Щоб перевірити поточного користувача, виконайте таку команду:

    ```
    aws sts get-caller-identity
    ```

## Створення кластера AWS EKS в AWS Console

Ви можете звернутися до відео на YouTube, яке демонструє кроки створення кластера EKS в консолі AWS:
https://www.youtube.com/watch?v=KxxgF-DAGWc

Крім того, ви можете звернутися безпосередньо до документації AWS: ["AWS Management Console and AWS CLI"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html)

## Завантаження образів до приватного реєстру AWS

Є кілька причин, чому ваші образи не можуть бути завантажені до загальнодоступного сховища образів, такого як Docker Hub.
Ви можете завантажити ваш образ до приватного реєстру AWS, виконавши наступні кроки:

1. Створіть новий репозиторій ECR (якщо його ще не створено): 

Приватне сховище Amazon ECR містить ваші образи Docker, образи Open Container Initiative (OCI) і сумісні з OCI артефакти. Більше інформації про приватний репозиторій Amazon ECR: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Repositories.html

```
aws ecr create-repository --repository-name my-app-repo --region <region> 
```

Замініть my-app-repo на бажану назву репозиторію, а <region> - на ваш регіон AWS (наприклад, us-west-1). 

2. Автентифікація Docker у вашому реєстрі ECR： 

```
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com 
```

Замініть <region> на ваш регіон AWS, а <account_id> на ідентифікатор вашого облікового запису AWS. 

3. Створіть свій образ Docker： 

```
docker build -t my-app:<tag> .
```

4. Позначте свій Docker-образ, щоб його можна було перенести до вашого репозиторію ECR: 

```
docker tag my-app:<tag> <account_id>.dkr.ecr.<region>.amazonaws.com/my-app-repo:<tag>
```

Замініть <account_id> на ідентифікатор вашого облікового запису AWS, <region> на ваш регіон AWS, а my-app-repo на назву вашого репозиторію. 

5. Перенесіть ваш Docker-образ до сховища ECR за допомогою цієї команди: 

```
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/my-app-repo:latest
```
