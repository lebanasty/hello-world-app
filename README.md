# Hello World App Deployment with EKS

This repository is designed to provision an EKS cluster in AWS and deploy a **hello-world-app** into it. 


## Table of Contents

- [Prerequisites](#prerequisites)
  - [Setting Up Secrets and Environment Variables](#setting-up-secrets-and-environment-variables)
- [CI/CD Automation](#cicd-automation)
- [Accessing the Application](#accessing-the-application)
  - [Steps to Get the Application URL](#steps-to-get-the-application-url)
    - [If Using a ClusterIP Service (Default Option)](#if-using-a-clusterip-service-default-option)
    - [If Using a NodePort Service](#if-using-a-nodeport-service)
    - [If Using a LoadBalancer Service](#if-using-a-loadbalancer-service)
    - [If Ingress is Enabled](#if-ingress-is-enabled)
  - [Additional Notes](#additional-notes)

---

## Prerequisites

To successfully run the deployment, you must set the required environment variables. 

### Setting Up Secrets and Environment Variables

The easiest way to set these variables is by cloning the repository and configuring the secrets in the repository's settings. Ensure the following secrets are added:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`

Additionally, set the following environment variable:

- `AWS_REGION`

## CI/CD Automation

This repository leverages **GitHub Actions** to automate the deployment process. The workflow is triggered when changes are detected in any of the following directories:

- `hello-world-app`
- `helloworld`
- `terraform`

Upon detecting changes, GitHub Actions will run the respective jobs to provision the infrastructure and deploy the application.

## Accessing the Application

Once the deployment is complete, you can access the application using one of the methods below, depending on the type of service configured in your deployment. 

### Steps to Get the Application URL:

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
