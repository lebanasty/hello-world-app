
# EKS Deployment Pipeline

This README provides a comprehensive guide to the **EKS Deployment Pipeline** defined in the GitHub Actions workflow (`deploy.yml`). The pipeline automates the deployment of infrastructure, application containers, and Helm charts to manage a Kubernetes cluster on Amazon EKS. It is designed to handle changes in Terraform infrastructure, Helm charts, and application code.

## Overview

The **EKS Deployment Pipeline** workflow automates the following:

1. **Detect File Changes** - Determine which components have changed to optimize the execution.
2. **Build Docker Image** - Build and push a Docker image for the application when changes occur.
3. **Terraform Provisioning** - Create or update infrastructure using Terraform.
4. **Helm Deployment** - Package and deploy a Helm chart to the EKS cluster.

The pipeline is triggered by changes in specific directories, including Terraform infrastructure, Helm charts, and the application source code.

## Trigger Conditions

The workflow is triggered on pushes and pull requests to the `main` branch when changes occur in the following paths:

- `terraform/**` - Infrastructure as code (Terraform files)
- `helloworld/**` - Helm chart for deploying the application
- `hello-world-app/**` - Application source code
- `.github/workflows/deploy.yml` - Changes to the pipeline configuration

## Jobs in the Workflow

### 1. Detect File Changes

This job checks which components have changed since the last commit. It outputs the status of changes to determine which subsequent jobs should run.

- **Outputs**:
  - `terraform_changed`: Indicates if any Terraform files have changed.
  - `helm_changed`: Indicates if any Helm chart files have changed.
  - `app_changed`: Indicates if the application source code has changed.

### 2. Docker Build and Push

If the application code changes, this job:

- **Checks out** the repository.
- **Logs in** to Amazon ECR.
- **Builds** the Docker image for the application from the `hello-world-app/` directory.
- **Pushes** the Docker image to the ECR repository.
- **Uploads** a status artifact indicating the Docker build is complete.

**Note**: This job runs only when changes are detected in the application code directory (`hello-world-app/`).

### 3. Terraform Provisioning

If Terraform files are modified, this job provisions or updates the Kubernetes infrastructure:

- **Checks out** the repository.
- **Sets up** Terraform and AWS credentials.
- **Initializes** Terraform.
- **Generates** a Terraform plan (`tfplan.binary`) for changes to the infrastructure.
- **Uploads** the Terraform plan as an artifact.
- **Applies** the Terraform plan using `terraform apply -auto-approve`.
- **Outputs** the kubeconfig file as an artifact to be used by subsequent jobs.

**Note**: This job runs only when changes are detected in the Terraform directory (`terraform/`).

### 4. Helm Deployment

This job runs if there are changes in the Helm charts, Terraform, or application code:

- **Checks out** the repository.
- **Downloads** the Docker status and Terraform status artifacts from previous jobs.
- **Sets up** Helm.
- **Configures AWS** credentials.
- **Handles kubeconfig**:
  - Downloads kubeconfig if Terraform changes were detected.
  - Otherwise, fetches the kubeconfig from the existing EKS cluster.
- **Packages** the Helm chart from `helloworld/`.
- **Uploads** the packaged Helm chart as an artifact.
- **Installs or upgrades** the Helm release (`hello-world-release`) on the EKS cluster.

## Artifact Management

- **Docker Status**: The `docker-status.txt` artifact signals that the Docker build and push job has completed.
- **Terraform Plan**: The `tfplan.binary` file contains the Terraform plan for infrastructure changes, allowing review before applying changes.
- **Kubeconfig**: The kubeconfig file is used to authenticate and connect to the EKS cluster.
- **Helm Chart Package**: The packaged Helm chart (`helloworld-*.tgz`) is uploaded as an artifact for use in deployment.

## Conditional Execution

The workflow uses conditional checks to avoid running unnecessary jobs:

- The **Docker Build** job only runs if the application code changes.
- The **Terraform** job only runs if there are infrastructure changes.
- The **Helm Deployment** job runs if any relevant changes are detected in the Terraform, Helm, or application directories.

## Usage Instructions

To use this CI/CD pipeline, push changes to the `main` branch or open a pull request, making sure the relevant directories are modified. The workflow automatically detects changes and triggers the appropriate sequence of jobs.

- **Review Terraform Plan**: Check the Terraform plan artifact generated to understand proposed changes to infrastructure before applying.
- **Helm Deployment**: Helm is used to deploy or upgrade the application on EKS. Packaged Helm charts are stored as artifacts for reuse.

### Prerequisites

- **AWS Credentials**: Stored as GitHub secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ACCOUNT_ID`) for authenticating with AWS services.
- **Terraform and Helm Setup**: GitHub Actions use preconfigured Terraform and Helm setup actions to ensure the proper versions are used.

## Enhancements and Recommendations

- **Manual Approval for Terraform Apply**: Add a manual approval step for Terraform apply if deploying to production to ensure additional verification.
- **Artifact Retention**: Manage retention periods for artifacts such as the Terraform plan and packaged Helm chart to optimize storage.
- **Additional Testing**: Consider adding testing stages to verify the deployed application's functionality after Helm deployment.

This CI/CD workflow automates infrastructure provisioning, application deployment, and ensures consistent, repeatable deployments to an Amazon EKS cluster, while optimizing for changes in specific components to reduce unnecessary runs.
