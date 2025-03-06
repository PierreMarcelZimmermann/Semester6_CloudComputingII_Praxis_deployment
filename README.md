# Semester6_CloudComputingII_Praxis_Deploy

This project was created for an exam at DHBW.  
It consists of a small application and the deployment process. The app uses Azure AI Vision to analyze images, and it stores the results in a database. When an image is sent for analysis again, the results are retrieved from the database instead of calling the API again.

## Prerequisites

Before deploying the application, make sure the following tools are installed:

- **Terraform**: Install Terraform by following the instructions on the [official website](https://www.terraform.io/downloads).
- **Azure CLI**: You need the Azure CLI to log in to your Azure account. Install it from the [official page](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
- **Azure Subscription**: Ensure you have an Azure account with sufficient permissions to create resources.

## Deployment

This section explains the steps to deploy the app. The deployment process is automated using Ansible, but you must follow these preliminary steps to prepare your environment.

### Step 1: Set Up Azure Credentials

Terraform requires your Azure credentials to deploy the necessary resources. To make this process easy, you can create an `.env` file in the root of your project. This file will contain your Azure credentials, which Terraform will use to authenticate and deploy resources.

1. **Create the `.env` file**

In the root directory of your project, create a file named `.env` and add the following environment variables with your Azure credentials:

```bash
ARM_CLIENT_ID="your-client-id"
ARM_CLIENT_SECRET="your-client-secret"
ARM_SUBSCRIPTION_ID="your-subscription-id"
ARM_TENANT_ID="your-tenant-id"
```
Note: Replace the placeholders with your actual Azure Service Principal credentials. You can create a service principal using the Azure CLI:
```bash
az ad sp create-for-rbac --name "your-app-name" --role contributor --scopes /subscriptions/{subscription-id} --sdk-auth
```

2. Configure Terraform
If you wish to change the SKU or ressouce region feel free to edit the variables.tf in the terraform directory.