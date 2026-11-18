terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project               = var.project_id
  user_project_override = true
}

resource "google_bigquery_analytics_hub_data_exchange" "exchange" {
  project                             = var.project_id
  location                            = var.location
  data_exchange_id                    = var.data_exchange_id
  display_name                        = var.data_exchange_id
  description                         = "Private dataset sharing with approved Unravel subscribers."
  primary_contact                     = var.primary_contact
  discovery_type                      = "DISCOVERY_TYPE_PRIVATE"
  log_linked_dataset_query_user_email = true
}

resource "google_bigquery_analytics_hub_listing" "dataset" {
  for_each = { for listing in var.listings : listing.listing_id => listing }

  project                             = var.project_id
  location                            = google_bigquery_analytics_hub_data_exchange.exchange.location
  data_exchange_id                    = google_bigquery_analytics_hub_data_exchange.exchange.data_exchange_id
  listing_id                          = each.key
  display_name                        = each.key
  description                         = "Private dataset sharing - Dataset: ${each.value.source_dataset_id}"
  primary_contact                     = var.primary_contact
  discovery_type                      = "DISCOVERY_TYPE_PRIVATE"
  log_linked_dataset_query_user_email = true

  bigquery_dataset {
    dataset = "projects/${var.project_id}/datasets/${each.value.source_dataset_id}"
  }
}

resource "google_bigquery_analytics_hub_data_exchange_iam_member" "subscriber" {
  for_each = var.subscriber_members

  project          = var.project_id
  location         = google_bigquery_analytics_hub_data_exchange.exchange.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.exchange.data_exchange_id
  role             = "roles/analyticshub.subscriber"
  member           = each.value
}
