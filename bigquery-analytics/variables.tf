variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The region in which to provision resources."
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "The location for the Data Exchange and Listing (e.g., US, EU)."
  type        = string
  default     = "US"
}

variable "data_exchange_id" {
  description = "The ID of the BigQuery Analytics Hub Data Exchange."
  type        = string
}

variable "primary_contact" {
  description = "The primary contact email for the Data Exchange."
  type        = string
}

variable "listings" {
  description = <<EOT
List of listings to create. Each object must contain:
- listing_id:           The Analytics Hub listing ID.
- source_dataset_id:    The ID of the source dataset containing the table.
- shared_table_id:      The full resource name of the table to share (e.g., projects/my-project/datasets/my-dataset/tables/my-table).
EOT

  type = list(object({
    listing_id        = string
    source_dataset_id = string
    shared_table_id   = string
  }))
}
variable "subscriber_emails" {
  description = "The email addresses of the users to grant subscriber permissions to."
  type        = list(string)
}
