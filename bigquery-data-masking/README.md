# GCP BigQuery Data Masking Setup using Terraform

Automate the deployment of GCP resources required for **Unravel BigQuery data masking integration** using Cloud Run and Terraform.

---

## 🔧 Prerequisites

Make sure you have the following tools installed:

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install)
- [Git](https://git-scm.com/downloads)

---

## 🚀 Setup Instructions

### 1. Clone this Repository

git clone https://github.com/unraveldata-org/unravel-bq-data-masking.git
cd unravel-bq-data-masking


### 2. Authenticate with Google Cloud

gcloud init
gcloud auth application-default login



### 3. Customize Configuration

#### a. Copy the Example Input File

cp input.tfvars.example input.tfvars


#### b. Edit `input.tfvars`

Open `input.tfvars` in your preferred editor and update the values to match your environment:

GCP Project ID where resources will be created

project_id = "your-project-id"
Region where Cloud Run should be deployed (e.g., "us-central1")

region = "your-region"
Name of the Cloud Run service

service_name = "unravel-bq-data-masking"
Docker image to be deployed

docker_image = "us-central1-docker.pkg.dev/unravel-flat-rate-test/cloud-run-source-deploy/bq-transform-fns:555b70b"


*Example:*

project_id = "my-gcp-project"

region = "us-central1"

service_name = "unravel-bq-data-masking"

docker_image = "us-central1-docker.pkg.dev/unravel-flat-rate-test/cloud-run-source-deploy/bq-transform-fns:555b70b"

---

## 🧪 Terraform Workflow

### 4. Initialize Terraform

terraform init


### 5. Review the Plan

terraform plan --var-file=input.tfvars


### 6. Apply the Configuration

terraform apply --var-file=input.tfvars

*Confirm with `yes` when prompted.*

---

## ✅ Check Outputs

After applying, you can inspect the outputs:

terraform output

---

## 🧹 Destroy Resources

To remove all provisioned resources:

terraform destroy --var-file=input.tfvars
