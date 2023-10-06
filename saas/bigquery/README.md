![Unravel](https://www.unraveldata.com/wp-content/themes/unravel-child/src/images/unLogo.svg)  
# GCP Resource Creation and Configuration for Unravel Bigquery Integration
![Terraform Workflow](https://github.com/unraveldata-org/unravel-terraform-scripts/actions/workflows/run-prcheck.yml/badge.svg)

Project for managing Unravel Bigquery GCP resource configuration! This project aims to simplify the process of setting up and managing Google Cloud resources using Terraform. Below are the instructions to get started:

## Before You Begin
Before you start, make sure you have the following software installed on your computer:
```bash
git
curl
vim
```

### Step 1: Download Terraform
Terraform is a tool we'll use for this integration. Follow these simple steps:

1. Visit [Terraform's download page](https://www.terraform.io/downloads).
2. Follow the instructions provided on the [Terraform install page](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli) to complete installation.
 
### Step 2: Configure Google Cloud
To connect to Google Cloud, you'll need to set up Google Cloud SDK (gcloud). Follow these steps:

1. Visit [Google Cloud SDK installation guide](https://cloud.google.com/sdk/docs/install-sdk).
2. Follow the instructions based on your machine's architecture and operating system.

### Step 3: Initialize Google Cloud
To connect to Google Cloud, run these commands in your terminal:

```bash
gcloud init
gcloud auth application-default login
```

## Setting Up Unravel BigQuery Integration
Unravel requires few permissions to access Bigquery API/Logs from the GCP projects to generate insights. These projects can be classified into 2 based on the characteristics.

1. Monitoring Project(s): These are where BigQuery jobs run and need to be integrated with Unravel. Most of your projects likely fall into this category.

2. Admin Project: These are projects where BigQuery Slot reservations/Commitments are defined. These projects may or may not run BigQuery jobs.

Unravel VM Identity-based authentication  for querying BigQuery API/logs. During onboarding, Unravel will provide you with a service account.

### Step 4: VM Identity-Based Authentication
We've automated the resource creation and configuration for you. Here's what you need to do:

1. Unravel will provide you with a "Service Account" during onboarding.
2. The Terrafrom script in this repo will create IAM roles in your "Monitoring Projects" and "Admin Projects" in your GCP projects.
3. These roles will be linked to the "Service Account" provided by Unravel.

## Customizing Your Configuration
To tailor the integration to your specific needs, you'll create a Terraform input file. Here's how:

### Step 5: Create a Terraform Input File
Start by duplicating the example input file named input.tfvars.example. Rename it to input.tfvars.

```bash
cp input.tfvars.example input.tfvars
```

### Step 6: Customize for VM Identity-Based Authentication
Now, open the input.tfvars file and make these updates:

unravel_service_account (Required, string): Update this with the Service Account provided by Unravel during onboarding. Make sure it's accurate for a successful integration.

monitoring_project_ids (Required, map): Provide a list of GCP Project IDs where BigQuery Jobs are running and need monitoring. Include the corresponding subscription name to use for each project.

admin_project_ids (Optional, list): If you have Admin Projects where BigQuery slot reservations are configured, list their GCP Project IDs here. Otherwise, leave it empty.

## Storing Terraform State
To keep things organized, we recommend configuring a central storage for your Terraform state file:

### Step 7: Configure Terraform Backend
Copy the example backend configuration file using this command:

```bash
cp backend.tf.example backend.tf
```

Update the backend.tf file with the Google Storage Path which the user running Terraform has access. 

## Creating Your Resources
With everything set up, it's time to create the necessary resources:

### Step 8: Run Terraform
Navigate to the terraform directory and run these commands:

```bash
cd saas/bigquery
terraform init
terraform plan --var-file=input.tfvars
terraform apply --var-file=input.tfvars
```

## Checking Your Resources
To see a list of the resources created by Terraform, run this command:

```bash
terraform output
```

## Removing Resources
To undo everything created by Terraform, run this command:

### Step 9: Destroy Resources
Navigate to the terraform directory and execute:

```bash
cd terraform
terraform destroy --var-file=input.tfvars
```

## Documentation and Support
For detailed documentation, visit our webpage.

If you have any questions or encounter issues during the integration, reach out to our support team at support@unraveldata.com. We're here to help.

We value your feedback! If you have suggestions or improvements for this guide or the repository, please open an issue or submit a pull request.

Thank you for choosing Unravel for your big data observability needs. We look forward to helping you optimize your big data applications and enhance your data platform's performance and efficiency. Happy Unraveling!






