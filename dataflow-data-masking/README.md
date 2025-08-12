GCP BigQuery Data Masking Setup using Terraform

Automate the deployment of GCP resources required for Unravel BigQuery data masking integration using Cloud Run and Terraform.
🔧 Prerequisites

Make sure you have the following tools installed:

    Terraform
    Google Cloud SDK (gcloud)
    Git

🚀 Setup Instructions
1. Clone this Repository

git clone https://github.com/unraveldata-org/unravel-terraform-scripts.git

cd dataflow-data-masking
2. Authenticate with Google Cloud

gcloud init

gcloud auth application-default login
3. Customize Configuration
a. Copy the Example Input File

cp input.tfvars.example input.tfvars
b. Edit input.tfvars

Open input.tfvars in your preferred editor and update the placeholder values:

    PROJECT_ID – GCP project ID where the Dataflow job will be created.

    REGION – Region where the job will run (e.g., us-central1).

    BUCKET_NAME – GCS bucket storing your Dataflow template and temp files.

    DATASET.INPUT_TABLE – Source BigQuery dataset and table.

    PROJECT_ID.DATASET.OUTPUT_TABLE – Destination BigQuery dataset and table.

🧪 Terraform Workflow
4. Initialize Terraform

terraform init
5. Review the Plan

terraform plan --var-file=input.tfvars
6. Apply the Configuration

terraform apply --var-file=input.tfvars

Confirm with yes when prompted.
✅ Check Outputs

After applying, you can inspect the outputs:

terraform output
🧹 Destroy Resources

To remove all provisioned resources:

terraform destroy --var-file=input.tfvars
