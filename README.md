# Semester6_CloudComputingII_Praxis_Deploy
This project was created for an exam at DHBW. It showcases cloud development basics.
SkySight is an application deployed using Terraform and Ansible. This guide will walk you through the steps to deploy the application.
## Prerequisites
Before deploying the application, make sure the following tools are installed:
- **Terraform**: Install Terraform by following the instructions on the [official website](https://www.terraform.io/downloads).
- **Azure CLI**: You need the Azure CLI to log in to your Azure account. Install it from the [official page](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
- **Azure Subscription**: Ensure you have an Azure account with sufficient permissions to create resources.
- **Ansible**: Install Ansible by following the instructions on the [official website](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
## Deployment
This section explains the steps to deploy the app. The deployment process is automated using Ansible, but you must follow these preliminary steps to prepare your environment.
### Azure Auth
Log in using az login with an Azure account that has sufficient permissions to create and manage resources.
### Terraform 
- Use `cd /terraform` to navigate into the terraform directory
- Run `terraform init` 
- Run `terraform apply --auto-approve` *twice* to ensure that the resources are correctly provisioned and any necessary dependencies are initialized
### Ansible
- Use `cd /ansible` to navigate into the ansible directory
- Install requirements using `pip install -r requirements.txt`
- Use `ansible-playbook -i inventory.ini deploy.yml` to deploy the app
### Use App
- Determine the vm's public ip (terraform output or inventory.ini)
- Frontend runs on port 3000
- Backend runs on port 5000
- Logging dashboard runs on port 5001
### Free Resources
- Use `cd /terraform` to navigate into the terraform directory
- Run `terraform destroy --auto-approve` to remove all provisioned resources and avoid ongoing costs in Azure 
