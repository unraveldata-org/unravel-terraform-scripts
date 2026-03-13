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
  display_name     = var.data_exchange_id
  description      = "Secure data sharing environment for engineering analytics."
  primary_contact  = var.primary_contact

  sharing_environment_config {
    dcr_exchange_config {}
  }

  log_linked_dataset_query_user_email = true
}

# --- 4. The Listings (One per table for DCR) ---
resource "google_bigquery_analytics_hub_listing" "unravel_listing" {
  # Key by listing_id to ensure uniqueness and easy reference.
  for_each = { for l in var.listings : l.listing_id => l }

  provider         = google-beta
  location         = google_bigquery_analytics_hub_data_exchange.clean_room.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id

  # listing_id must be unique per listing.
  listing_id      = each.value.listing_id
  display_name    = each.value.listing_id
  description     = "DCR Listing for analytics sharing - Table: ${element(split("/", each.value.shared_table_id), length(split("/", each.value.shared_table_id)) - 1)}"
  primary_contact = var.primary_contact

  bigquery_dataset {
    dataset = "projects/${var.project_id}/datasets/${each.value.source_dataset_id}"
    selected_resources {
      table = each.value.shared_table_id
    }
  }

  restricted_export_config {
    enabled = true
  }
}

# --- 5. IAM: Grant Permission to Subscribers ---
resource "google_bigquery_analytics_hub_data_exchange_iam_member" "subscriber_permission" {
  for_each         = toset(var.subscriber_emails)
  provider         = google-beta
  project          = var.project_id
  location         = google_bigquery_analytics_hub_data_exchange.clean_room.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  role             = "roles/analyticshub.subscriber"
  member           = "user:${each.value}"
}
