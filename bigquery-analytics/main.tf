terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.30.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  
  # This helps resolve the "quota project" error with local ADC
  user_project_override = true
  billing_project       = var.project_id
}

# Enable the Analytics Hub API
resource "google_project_service" "analyticshub" {
  service            = "analyticshub.googleapis.com"
  disable_on_destroy = false
}

# 1. Reference the existing Dataset (US Region)
data "google_bigquery_dataset" "unravel_share_us" {
  dataset_id = "unravel_share_US"
}

# 2. Create a Standard Analytics Hub Data Exchange
resource "google_bigquery_analytics_hub_data_exchange" "clean_room" {
  data_exchange_id = var.data_exchange_id
  display_name     = var.data_exchange_display_name
  description      = "Data Exchange for sharing BigQuery metadata with Unravel"
  location         = "US"
  primary_contact  = var.primary_contact_email

  log_linked_dataset_query_user_email = var.log_linked_dataset_query_user_email

  # Note: Removed dcr_exchange_config to support sharing the entire dataset
  
  # Ensure API is enabled first
  depends_on = [google_project_service.analyticshub]
}

# 3. Create a Listing to share the ENTIRE dataset
resource "google_bigquery_analytics_hub_listing" "unravel_listing" {
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  listing_id       = "unravel_share_listing"
  display_name     = "Unravel Health Check Data"
  description      = "Listing containing BigQuery metadata for Unravel Health Check"
  location         = "US"

  primary_contact = var.primary_contact_email

  log_linked_dataset_query_user_email = var.log_linked_dataset_query_user_email

  bigquery_dataset {
    # Sharing the entire dataset is supported in standard exchanges
    dataset = data.google_bigquery_dataset.unravel_share_us.id
  }
}

# 4. Grant Subscriber Access to Unravel
resource "google_bigquery_analytics_hub_listing_iam_member" "subscriber" {
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  listing_id       = google_bigquery_analytics_hub_listing.unravel_listing.listing_id
  location         = "US"
  role             = "roles/analyticshub.subscriber"
  member           = var.unravel_principal_email
}

# 5. Automate Subscription (Subscriber Side) using gcloud
# This is a workaround because Terraform doesn't support Standard Listing subscriptions yet.
resource "null_resource" "subscribe_to_listing" {
  count = var.enable_subscription ? 1 : 0

  triggers = {
    listing_id = google_bigquery_analytics_hub_listing.unravel_listing.id
  }

  provisioner "local-exec" {
    command = <<EOT
      curl -X POST \
        -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json; charset=utf-8" \
        -d '{
          "destination_dataset": {
            "dataset_reference": {
              "project_id": "${var.subscriber_project_id}",
              "dataset_id": "${var.destination_dataset_id}"
            },
            "location": "${var.region}"
          }
        }' \
        "https://analyticshub.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/dataExchanges/${var.data_exchange_id}/listings/${google_bigquery_analytics_hub_listing.unravel_listing.listing_id}:subscribe"
    EOT
  }

  depends_on = [google_bigquery_analytics_hub_listing_iam_member.subscriber]
}
