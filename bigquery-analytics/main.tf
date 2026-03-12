# --- 1. Provider Configuration ---
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
}

provider "google-beta" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
}

# --- 2. The Data Clean Room (Exchange) ---
resource "google_bigquery_analytics_hub_data_exchange" "clean_room" {
  provider         = google-beta
  location         = var.location
  data_exchange_id = var.data_exchange_id
  display_name     = var.data_exchange_display_name
  description      = "Secure data sharing environment for engineering analytics."
  primary_contact  = var.primary_contact

  sharing_environment_config {
    dcr_exchange_config {}
  }

  log_linked_dataset_query_user_email = true
}

# --- 3. Reference Existing Dataset ---
data "google_bigquery_dataset" "unravel_ds" {
  dataset_id = var.source_dataset_id
  project    = var.project_id
}

# --- 4. The Listings (One per table for DCR) ---
resource "google_bigquery_analytics_hub_listing" "unravel_listing" {
  for_each = toset(var.shared_table_ids)

  provider         = google-beta
  location         = google_bigquery_analytics_hub_data_exchange.clean_room.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  
  # listing_id must be unique. Extracting the table name from the full resource path.
  listing_id       = "${var.listing_id}_${element(split("/", each.value), length(split("/", each.value)) - 1)}"
  display_name     = "${var.listing_display_name} - ${element(split("/", each.value), length(split("/", each.value)) - 1)}"
  description      = "DCR Listing for analytics sharing - Table: ${element(split("/", each.value), length(split("/", each.value)) - 1)}"

  bigquery_dataset {
    dataset = data.google_bigquery_dataset.unravel_ds.id
    selected_resources {
      table = each.value
    }
  }

  log_linked_dataset_query_user_email = true

  restricted_export_config {
    enabled = true
  }
}

# --- 5. IAM: Grant Permission to Subscriber ---
resource "google_bigquery_analytics_hub_data_exchange_iam_member" "subscriber_permission" {
  for_each         = toset(var.subscriber_emails)
  provider         = google-beta
  project          = var.project_id
  location         = google_bigquery_analytics_hub_data_exchange.clean_room.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  role             = "roles/analyticshub.subscriber"
  member           = "user:${each.value}"
}

# --- 6. The Automated Subscription ---
resource "google_bigquery_analytics_hub_data_exchange_subscription" "unravel_sub" {
  provider = google-beta
  project  = var.project_id
  location = var.location

  data_exchange_project  = var.project_id
  data_exchange_location = var.location
  data_exchange_id       = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id

  subscription_id    = var.subscription_id
  subscriber_contact = var.subscriber_emails[0]

  destination_dataset {
    location = var.location
    dataset_reference {
      project_id = var.project_id
      dataset_id = var.destination_dataset_id
    }
    friendly_name = "Subscribed Data Clean Room"
  }

  refresh_policy = "ON_READ"

  # Wait for IAM and Listings to propagate
  depends_on = [
    google_bigquery_analytics_hub_data_exchange_iam_member.subscriber_permission,
    google_bigquery_analytics_hub_listing.unravel_listing
  ]
}
