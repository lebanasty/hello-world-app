
# Hello World App Deployment with EKS

This repository is designed to provision an EKS cluster in AWS and deploy a **hello-world-app** into it.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
  - [Tools to Install](#tools-to-install)
  - [Setting Up AWS Account and Secrets](#setting-up-aws-account-and-secrets)
  - [AWS IAM Permissions](#aws-iam-permissions)
- [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
  - [Step 1: Clone the Repository](#step-1-clone-the-repository)
  - [Step 2: Configure Secrets and Environment Variables](#step-2-configure-secrets-and-environment-variables)
  - [Step 3: Build and Push the Docker Image to Amazon ECR](#step-3-build-and-push-the-docker-image-to-amazon-ecr)
  - [Step 4: Trigger the CI/CD Pipeline](#step-4-trigger-the-cicd-pipeline)
- [Accessing the Application](#accessing-the-application)
  - [Steps to Get the Application URL](#steps-to-get-the-application-url)
  - [Additional Notes](#additional-notes)

---

## Introduction

This guide walks you through deploying the application from scratch with minimal technical expertise. 

---

## Prerequisites

Before deploying the application, ensure the following tools, permissions, and accounts are set up:

### Tools to Install

You need to install the following tools:

1. **Git**: To clone the repository. [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
2. **Terraform**: To provision the infrastructure. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. **Helm**: To manage Kubernetes deployments. [Install Helm](https://helm.sh/docs/intro/install/)
4. **Docker**: To build and push Docker images. [Install Docker](https://docs.docker.com/get-docker/)
5. **AWS CLI**: To interact with AWS services. [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

### Setting Up AWS Account and Secrets

- **AWS Account**: Create an AWS account if you don’t have one. [Sign Up for AWS](https://aws.amazon.com/)
- **Access Credentials**: Generate an `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the AWS Management Console by creating a new IAM user with programmatic access.

### AWS IAM Permissions

Ensure your IAM user or role has permissions for the following services:

- `ec2`
- `autoscaling`
- `eks`
- `iam`
- `elasticloadbalancing`
- `s3`
- `ecr`
- `kms`
- `logs`
- `cloudwatch`
- `route53`

---

## Step-by-Step Deployment Guide

### Step 1: Clone the Repository

1. Open a terminal or command prompt on your computer.
2. Run the following command to clone this repository:
   ```bash
   git clone https://github.com/<username>/<repository-name>.git
   ```
3. Navigate to the cloned repository:
   ```bash
   cd <repository-name>
   ```

---

### Step 2: Configure Secrets and Environment Variables

1. Go to the repository’s **Settings** on GitHub.
2. In the **Secrets and Variables** section, add the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_ACCOUNT_ID`
3. Add the following environment variable:
   - `AWS_REGION`: Set this to your desired AWS region (e.g., `us-west-2`).

---

### Step 3: Build and Push the Docker Image to Amazon ECR

1. **Authenticate Docker to Amazon ECR**:
   ```bash
   aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com
   ```

2. **Build the Docker image**:
   Navigate to the `hello-world-app` directory and build the Docker image:
   ```bash
   docker build -t hello-world-app .
   ```

3. **Tag the Docker image**:
   Tag the image with the ECR repository URL:
   ```bash
   docker tag hello-world-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/hello-world-app:latest
   ```

4. **Push the Docker image to ECR**:
   Push the image to your ECR repository:
   ```bash
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/hello-world-app:latest
   ```

---

### Step 4: Trigger the CI/CD Pipeline

The CI/CD pipeline is automated using **GitHub Actions**. Here's how to start it:

1. Make changes to any of the following directories to trigger the pipeline:
   - `hello-world-app`
   - `helloworld`
   - `terraform`
2. Push your changes to the GitHub repository:
   ```bash
   git add .
   git commit -m "Trigger pipeline"
   git push origin main
   ```
3. The pipeline will automatically:
   - Provision an EKS cluster using Terraform.
   - Deploy the `hello-world-app` using Helm.

Monitor the pipeline’s progress in the **Actions** tab of your GitHub repository.

---

## Accessing the Application

Once the deployment is complete, you can access the application using one of the methods below, depending on the type of service configured in your deployment. 

### Steps to Get the Application URL

1. **If Using a ClusterIP Service (Default Option):**
   - Use port-forwarding to access the application:
     ```bash
     export POD_NAME=$(kubectl get pods --namespace <namespace> -l "app.kubernetes.io/name=<app-name>,app.kubernetes.io/instance=<instance-name>" -o jsonpath="{.items[0].metadata.name}")
     kubectl port-forward $POD_NAME 8080:80
     ```
   - Open your browser and visit:
     ```
     http://127.0.0.1:8080
     ```

2. **If Using a NodePort Service:**
   - Run these commands to get the NodePort and IP address of the node:
     ```bash
     export NODE_PORT=$(kubectl get --namespace <namespace> -o jsonpath="{.spec.ports[0].nodePort}" services <service-name>)
     export NODE_IP=$(kubectl get nodes --namespace <namespace> -o jsonpath="{.items[0].status.addresses[0].address}")
     echo http://$NODE_IP:$NODE_PORT
     ```
   - Open the displayed URL in your browser.

3. **If Using a LoadBalancer Service:**
   - Note: It may take a few minutes for the LoadBalancer IP to be available.
   - Run the following command to watch the status:
     ```bash
     kubectl get --namespace <namespace> svc -w <service-name>
     ```
   - Once the IP address is available, access the application at:
     ```
     http://<LoadBalancer-IP>:<port>
     ```

4. **If Ingress is Enabled:**
   - Run the following commands to get the application URL:
     ```bash
     kubectl get ingress --namespace <namespace>
     ```
   - Access the application at the URL provided by the ingress configuration.

### Additional Notes

- Refer to the `NOTES.txt` file in the Helm chart for exact commands and further details specific to your configuration.
- Replace `<namespace>`, `<service-name>`, `<app-name>`, and `<instance-name>` with the appropriate values for your deployment.

---

For detailed instructions and troubleshooting, refer to the documentation or the comments within the workflow files.
