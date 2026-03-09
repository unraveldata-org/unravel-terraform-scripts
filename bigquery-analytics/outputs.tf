output "dataset_id" {
  value = data.google_bigquery_dataset.unravel_share_us.dataset_id
  description = "The ID of the existing BigQuery Dataset."
}

output "data_exchange_id" {
  value = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  description = "The ID of the Analytics Hub Data Exchange (Clean Room)."
}

output "listing_id" {
  value = google_bigquery_analytics_hub_listing.unravel_listing.listing_id
  description = "The ID of the Listing shared with Unravel."
}

output "listing_resource_name" {
  value = google_bigquery_analytics_hub_listing.unravel_listing.name
  description = "The full resource name of the Listing. Share this or the URL with Unravel."
}

output "next_steps" {
  value = <<EOT
Infrastructure updated to use the existing dataset!
Next steps (as per PDF Section 1.7.1 & 1.7.2):
1. If not already done, run the Python notebook `apis_to_tables.ipynb` to fetch API data into the dataset: ${data.google_bigquery_dataset.unravel_share_us.dataset_id}
2. Execute the SQL procedures to download metadata from Information Schema.
3. The data is now automatically shared via the Analytics Hub Listing: ${google_bigquery_analytics_hub_listing.unravel_listing.listing_id}
EOT
}
