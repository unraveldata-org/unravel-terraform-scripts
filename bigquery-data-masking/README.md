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

Copy the example input file and edit with your project-specific values:

cp input.tfvars.example input.tfvars


Edit `input.tfvars`:

input.tfvars
GCP Project ID where resources will be created
project_id = "your-project-id"

Region where Cloud Run should be deployed
region = "your-region" # e.g., "us-central1"

Name of the Cloud Run service
service_name = "unravel-bq-data-masking"

Docker image to be deployed
docker_image = "us-central1-docker.pkg.dev/unravel-flat-rate-test/cloud-run-source-deploy/bq-transform-fns:555b70b"



---

## 🧪 Terraform Workflow

### 4. Initialize Terraform

terraform init


### 5. Review the Plan

terraform plan --var-file=input.tfvars


### 6. Apply the Configuration

*Confirm with `yes` when prompted.*

---

## ✅ Check Outputs

After applying, you can inspect the outputs:

terraform output


---

## 🧹 Destroy Resources

To remove all provisioned resources:

terraform destroy --var-file=input.tfvars
