![Unravel](https://www.unraveldata.com/wp-content/themes/unravel-child/src/images/unLogo.svg)  
# GCP Resource Creation and Configuration for Unravel Bigquery Integration

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
## Configuration and Installation
Unravel requires few permissions to access Bigquery API/Logs from the GCP projects to generate insights. These project can be classified in to 3 based on the charecterestics.

1. Monitoring projects: Projects where Biquery jobs are running and needs to be integrated with Unravel. Mostly all the projects will come uder this.
2. Admin Project: Project(s) where Bigquery Slot reservations/Commitments are defined. This Project may or may not be running Bigquery jobs.
3. Unravel Projects: The Project where Unravel VM is installed. It may or may not be running Bigquery jobs. 

Unravel supports three different authentication models for querying BigQuery API/logs:

1. VM Identity based authentication.
2. Single Key based authentication.
3. Multiple Key based authentication.

### VM Identity based authentication.
In this authentication model, A "Master service account" will be created under the "Unravel Project" and IAM roles will be created in each "Monitoring projects", "Admin Projects" and "Unravel Projects". Finally, these roles will be binded to the "Master Service account" created under the "Unravel Project".

The next step involves assigning the "Master Service account" to the Unravel VM. After Terraform creates the required resources, you must perform a one-time manual task: Stop the Unravel VM, change the Service account to the "Master Service account," and then restart the VM and Unravel.

### Single Key based authentication.
Similar to the VM Identity-based authentication model, a "Master service account" is created under the "Unravel Project," and IAM roles are set up in each "Monitoring Project," "Admin Project," and "Unravel Project." These roles are associated with the "Master Service account" in the "Unravel Project."

However, in this model, instead of assigning the "Master service account" to the VM, we generate a key for the "Master Service account." This key will be used by Unravel to gain access.

### Multiple Key based authentication.
In the Multikey based authentication model, an IAM role and a service account will be created in each project (Monitoring, Admin, and Unravel Projects). These roles and service accounts will be associated with one another, and a key will be generated for each project.

Choose the authentication model that best fits your requirements, 

## Create Terraform Input File
Begin by duplicating the provided example input file, input.tfvars.example, and renaming it as input.tfvars. This will serve as your working copy, where you'll input your specific project details.

```bash
cp input.tfvars.example input.tfvars
```

### Configuring for VM Identity based authentication.
Following variables should be updated.

unravel_project_id [Required](string): This variable should contain the GCP Project ID where the Unravel VM is installed. It is crucial to accurately specify this ID for successful integration with Unravel.

monitoring_project_ids [Required](list): Here, you must provide a list of GCP Project IDs where BigQuery Jobs are running and need monitoring. Ensure that all relevant projects are included in this list.

admin_project_ids [Optional](list): If your setup involves Admin Projects where BigQuery slot reservations are configured, provide a list of their GCP Project IDs in this variable. Otherwise, leave it empty or omit it.

key_based_authentication [Required](bool) : Set this variable as `false` 

### Configuring for Single Key based authentication.
Following variables should be updated.

unravel_project_id [Required](string): This variable should contain the GCP Project ID where the Unravel VM is installed. It is crucial to accurately specify this ID for successful integration with Unravel.

monitoring_project_ids [Required](list): Here, you must provide a list of GCP Project IDs where BigQuery Jobs are running and need monitoring. Ensure that all relevant projects are included in this list.

admin_project_ids [Optional](list): If your setup involves Admin Projects where BigQuery slot reservations are configured, provide a list of their GCP Project IDs in this variable. Otherwise, leave it empty or omit it.

key_based_authentication [Required](bool) : Set this variable as `true` 

### Configuring for Multi Key based authentication.
Following variables should be updated.

monitoring_project_ids [Required](list): Here, you must provide a list of GCP Project IDs where BigQuery Jobs are running and need monitoring. Ensure that all relevant projects are included in this list.

admin_project_ids [Optional](list): If your setup involves Admin Projects where BigQuery slot reservations are configured, provide a list of their GCP Project IDs in this variable. Otherwise, leave it empty or omit it.

key_based_authentication [Required](bool) : Set this variable as `false` 

multi_key_based_auth [Required](bool) : Set this variable as `true`


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

