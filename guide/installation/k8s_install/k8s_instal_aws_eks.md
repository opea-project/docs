# Kubernetes Installation using AWS EKS Cluster

In this document, we'll install Kubernetes v1.30 using [AWS EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html).


There are two ways to create a new Kubernetes cluster with nodes in AWS EKS:
- ["eksctl"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
- ["AWS Management Console and AWS CLI"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html).

In this document, we'll introduce the "AWS Management Console and AWS CLI" method.

## Prerequisites

Before starting this tutorial, you must install and configure the following tools and resources that you need to create and manage an Amazon EKS cluster.

- AWS CLI – A command line tool for working with AWS services, including Amazon EKS. For more information, see ["Installing, updating, and uninstalling the AWS CLI"](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) in the AWS Command Line Interface User Guide. After installing the AWS CLI, we recommend that you also configure it. For more information, see ["Quick configuration with aws configure"](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-configure-quickstart-config) in the AWS Command Line Interface User Guide.

- kubectl – A command line tool for working with Kubernetes clusters. For more information, see ["Installing or updating kubectl"](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html).

- Required IAM permissions – The IAM security principal that you're using must have permissions to work with Amazon EKS IAM roles, service linked roles, AWS CloudFormation, a VPC, and related resources. For more information, see ["Actions, resources, and condition keys for Amazon Elastic Kubernetes Service"](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonelastickubernetesservice.html) and ["Using service-linked roles"](https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html) in the IAM User Guide. You must complete all steps in this guide as the same user. To check the current user, run the following command:

    ```
    aws sts get-caller-identity
    ```

## Create AWS EKS Cluster in AWS Console

You can refer to the YouTube video that demonstrates the steps to create an EKS cluster in the AWS console:
https://www.youtube.com/watch?v=KxxgF-DAGWc

Alternatively, you can refer to the AWS documentation directly: ["AWS Management Console and AWS CLI"](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html)

## Uploading images to an AWS Private Registry

There are several reasons why your images might not be uploaded to a public image repository like Docker Hub.
You can upload your image to an AWS private registry using the following steps:

1. Create a new ECR repository (if not already created): 

An Amazon ECR private repository contains your Docker images, Open Container Initiative (OCI) images, and OCI compatible artifacts. More information about Amazon ECR private repository: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Repositories.html

```
aws ecr create-repository --repository-name my-app-repo --region <region> 
```

Replace my-app-repo with your desired repository name and <region> with your AWS region (e.g., us-west-1). 

2. Authenticate Docker to Your ECR Registry： 

```
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com 
```

Replace <region> with your AWS region and <account_id> with your AWS account ID. 

3. Build Your Docker Image： 

```
docker build -t my-app:<tag> .
```

4. Tag your Docker image so that it can be pushed to your ECR repository: 

```
docker tag my-app:<tag> <account_id>.dkr.ecr.<region>.amazonaws.com/my-app-repo:<tag>
```

Replace <account_id> with your AWS account ID, <region> with your AWS region, and my-app-repo with your repository name. 

5. Push your Docker image to the ECR repository with this command: 

```
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/my-app-repo:latest
```
