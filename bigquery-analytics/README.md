# BigQuery Analytics Hub Sharing (Unravel Health Check)

This Terraform configuration automates the setup of a **Google Cloud Analytics Hub Clean Room (Data Exchange)** and **Listing** to securely share BigQuery metadata with Unravel for health check purposes.

## Architecture
- **Analytics Hub API:** Automatically enabled.
- **Data Exchange:** Creates a "Clean Room" named `Unravel Data Share Clean Room`.
- **Listing:** Creates a listing `Unravel Health Check Data` sharing an existing BigQuery dataset.
- **IAM Permissions:** Grants the `roles/analyticshub.subscriber` role to the Unravel service account.

## Prerequisites
1. **GCP Project:** An existing project with billing enabled.
2. **Existing Dataset:** A BigQuery dataset named `unravel_share_US` must already exist in the `US` region.
3. **Terraform:** version 1.0 or higher.
4. **GCP Credentials:** Authenticated via `gcloud auth application-default login`.

## Deployment Steps

### 1. Configure Variables
Copy the example variable file and update it with your specific project details:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
- `project_id`: Your GCP Project ID.
- `primary_contact_email`: Your email address.
- `unravel_principal_email`: The Unravel Service Account (e.g., `serviceAccount:sa-name@unravel-data.iam.gserviceaccount.com`).

### 2. Authentication (Local Development)
If running from a local machine, ensure your ADC credentials include the project quota:
```bash
gcloud auth application-default login --update-adc --project YOUR_PROJECT_ID
```

### 3. Initialize & Apply
```bash
terraform init
terraform plan
terraform apply
```

## Outputs
After a successful apply, Terraform will provide:
- `listing_resource_name`: The ID you must share with the Unravel team so they can subscribe to the data.
- `next_steps`: Detailed instructions for data population.

## Data Population
This Terraform only handles the **sharing mechanism**. Ensure you follow the "Secure Data Sharing" PDF to:
1. Run the `apis_to_tables.ipynb` notebook.
2. Execute the required SQL procedures to populate the `unravel_share_US` dataset.

## Security Note
**DO NOT commit `terraform.tfvars` or `*.tfstate` files to version control.** These files contain sensitive information and your specific environment state.
