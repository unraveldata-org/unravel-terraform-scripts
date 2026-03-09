terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
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

# 2. Create the Analytics Hub Data Exchange (Clean Room)
resource "google_bigquery_analytics_hub_data_exchange" "clean_room" {
  data_exchange_id = "shared_data_unravel"
  display_name     = "Unravel Data Share Clean Room"
  description      = "Clean Room for sharing BigQuery metadata with Unravel"
  location         = "US"
  primary_contact  = var.primary_contact_email

  icon = null # Optional: You can add a base64 encoded image here if needed
  
  # Ensure API is enabled first
  depends_on = [google_project_service.analyticshub]
}

# 3. Create a Listing to share the dataset
resource "google_bigquery_analytics_hub_listing" "unravel_listing" {
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  listing_id       = "unravel_share_listing"
  display_name     = "Unravel Health Check Data"
  description      = "Listing containing BigQuery metadata for Unravel Health Check"
  location         = "US"

  primary_contact = var.primary_contact_email

  bigquery_dataset {
    # Use the ID from the existing dataset
    dataset = data.google_bigquery_dataset.unravel_share_us.id
  }
}

# 4. Grant Subscriber Access to Unravel
# This allows Unravel to subscribe to the listing and access the data.
resource "google_bigquery_analytics_hub_listing_iam_member" "subscriber" {
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  listing_id       = google_bigquery_analytics_hub_listing.unravel_listing.listing_id
  location         = "US"
  role             = "roles/analyticshub.subscriber"
  member           = var.unravel_principal_email
}

# Optional: Grant Publisher/Admin access to the user running this (if not implicitly owner)
# resource "google_bigquery_analytics_hub_data_exchange_iam_member" "admin" { ... }
