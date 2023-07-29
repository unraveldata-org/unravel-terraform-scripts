# GCP Resource Creation and Configuration for Unravel Bigquery Integration
[![Known Vulnerabilities](https://snyk.io/test/github/unraveldata-org/unravel-terraform-scripts/badge.svg)]

Project for managing Unravel Bigquery GCP resource configuration! This project aims to simplify the process of setting up and managing Google Cloud resources using Terraform. Below are the instructions to get started:

## Prerequisites
Before proceeding with the installation, ensure that you have the following packages installed on your system:

```bash
git
curl
vim
```

### Download Terraform
To download and install Terraform, follow these steps:

Visit https://www.terraform.io/downloads to access the Terraform downloads page and the instructions to install terraform.

### Configure gcloud
Before using this project, you need to authenticate with Google Cloud using gcloud. Follow the instructions provided at https://cloud.google.com/sdk/docs/install-sdk for a one-time configuration. You can find the install instruction nased on the Machine Arch and OS installed in the baove link.

### Initialize gcloud
To authenticate gcloud, execute the following commands:

```bash
gcloud init
gcloud auth application-default login
```
## Create Terraform Input File
To start using the project, create a Terraform input file and update it with your GCP project IDs:

```bash
cp input.tfvars.example input.tfvars
```
There are three major variables to update.

unravel_project_id [Required]:  The GCP Project ID where the Unravel VM is installed.
admin_project_ids [Optional]: The list of Admin Project IDs where the Bigquery slot reservations are configured.
project_ids [Required]: The list of Project IDs where the Bigquery Jobs are running and needs to be monitored.

## Configuring Terraform Backend.
It is always recommended to keep the state file in a central storage. Pleease configure `backend.tf` file in the repo to use Google Storage as your Terraform statefile storage.

```bash
cp backend.tf.example backend.tf
```
Update the file with an already existing Google Storage Path where the user executing the terrafrom have access to.

## Run Terraform to Create Resources
Run Terraform commands in the terraform directory:
``` bash
cd bigquery
terraform init
terraform plan --var-file=input.tfvars
terraform apply --var-file=input.tfvars
```

## List the Resources Created by Terraform
To view a list of resources created by Terraform, execute the following command:

```bash
terraform output
```

## Destroy the Resources Created by Terraform
To remove all changes made through Terraform, execute the following command:

```bash
cd terraform
terraform destroy --var-file=input.tfvars
```

## Documentation
All documentation for Unravel can be found on our webpage:
https://docs.unraveldata.com

## Support and Feedback
If you encounter any issues or have questions during the integration process, don't hesitate to reach out to our support team at support@unraveldata.com. We are here to assist you and ensure a successful setup.

We value your feedback! If you have any suggestions or improvements to contribute to this repository, please feel free to open an issue or submit a pull request.

Thank you for choosing Unravel for your big data observability needs. We are excited to help you optimize your big data applications and enhance your data platform's performance and efficiency. Happy Unraveling!

