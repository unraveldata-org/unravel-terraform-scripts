# BigQuery Analytics Hub Data Clean Room (DCR)

This Terraform project automates the setup of a **BigQuery Analytics Hub Data Clean Room**, allowing you to share specific tables from a source dataset with external subscribers in a secure, audited environment.

## Architecture Overview

1.  **Data Exchange**: Creates a BigQuery Analytics Hub Data Exchange configured as a Data Clean Room.
2.  **Listings**: Creates separate listings for each shared table (required by DCR API which mandates exactly one resource per listing).
3.  **IAM**: Grants `roles/analyticshub.subscriber` to the specified subscriber email.
4.  **Automated Subscription**: Automatically creates a subscription for the subscriber, linking the data to a destination dataset in their project.

## Prerequisites

-   Terraform >= 1.3.0
-   Google Cloud Provider >= 5.0.0
-   Google Cloud Project with BigQuery and Analytics Hub APIs enabled.
-   The user/service account running Terraform must have sufficient IAM permissions (BigQuery Admin or Analytics Hub Admin).

## Configuration

1.  Copy `terraform.tfvars.example` to `terraform.tfvars`:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

2.  Update `terraform.tfvars` with your specific details:
    -   `project_id`: Your Google Cloud Project ID.
    -   `source_dataset_id`: The ID of the dataset containing the tables you want to share.
    -   `shared_table_ids`: A list of full resource paths for the tables (e.g., `projects/MY_PROJECT/datasets/MY_DATASET/tables/MY_TABLE`).
    -   `subscriber_email`: The Google account email of the person who will access the data.
    -   `destination_dataset_id`: The ID of the dataset that will be created in the subscriber's project.

## Usage

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Preview Changes
```bash
terraform plan
```

### 3. Apply Changes
```bash
terraform apply
```

## Important Notes

-   **Subscriber Email Logging**: This project enables `log_linked_dataset_query_user_email`. **Note:** Once enabled on a listing or exchange, it cannot be disabled without recreating the resource.
-   **One Table Per Listing**: Due to Data Clean Room restrictions, each table in `shared_table_ids` is created as its own unique listing within the Data Exchange.
-   **Destination Dataset**: The `destination_dataset_id` must not already exist in the project, as the subscription resource will attempt to create it. If it exists, the apply will fail with a `409 Already Exists` error.

## Troubleshooting

-   **"Subscriber email logging cannot be disabled"**: This happens if you try to change the logging setting after the listing is created. If you must disable it, you must `terraform destroy` and re-apply.
-   **"Exactly one resource for data clean rooms"**: This occurs if multiple tables are added to a single `bigquery_dataset` block. This project solves this by using a `for_each` loop to create one listing per table.
