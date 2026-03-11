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

# --- 4. The Listing ---
resource "google_bigquery_analytics_hub_listing" "unravel_listing" {
  provider         = google-beta
  location         = google_bigquery_analytics_hub_data_exchange.clean_room.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  listing_id       = var.listing_id
  display_name     = var.listing_display_name
  description      = "DCR Listing for analytics sharing."

  bigquery_dataset {
    dataset = data.google_bigquery_dataset.unravel_ds.id
    selected_resources {
      table = var.shared_table_id
    }
  }

  restricted_export_config {
    enabled = true
  }
}

# --- 5. IAM: Grant Permission to Subscriber ---
resource "google_bigquery_analytics_hub_data_exchange_iam_member" "subscriber_permission" {
  provider         = google-beta
  project          = var.project_id
  location         = google_bigquery_analytics_hub_data_exchange.clean_room.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  role             = "roles/analyticshub.subscriber"
  member           = "user:${var.subscriber_email}"
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
  subscriber_contact = var.subscriber_email

  destination_dataset {
    location = var.location
    dataset_reference {
      project_id = var.project_id
      dataset_id = var.destination_dataset_id
    }
    friendly_name = "Subscribed Data Clean Room"
  }

  refresh_policy = "ON_READ"

  # Wait for IAM to propagate
  depends_on = [google_bigquery_analytics_hub_data_exchange_iam_member.subscriber_permission]
}
