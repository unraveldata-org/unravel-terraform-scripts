output "dataset_id" {
  value = data.google_bigquery_dataset.unravel_share_us.dataset_id
  description = "The ID of the existing BigQuery Dataset."
}

output "data_exchange_id" {
  value = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
  description = "The ID of the Analytics Hub Data Exchange."
}

output "listing_resource_name" {
  value = google_bigquery_analytics_hub_listing.unravel_listing.name
  description = "The full resource name of the Listing. SHARE THIS WITH UNRAVEL."
}

output "next_steps" {
  value = <<EOT
Data Exchange and Listing created successfully!

Next steps for sharing:
1. POPULATE DATA: Run your Python notebook and SQL procedures to fill the dataset: ${data.google_bigquery_dataset.unravel_share_us.dataset_id}
2. SHARE LINK: Provide the following resource name to the Unravel team:
   ${google_bigquery_analytics_hub_listing.unravel_listing.name}
3. SUBSCRIBE: The Unravel team (or you, using their account) can now go to 'Analytics Hub' in the GCP Console, find this listing, and click 'SUBSCRIBE' to create a linked dataset in their project.
EOT
}
