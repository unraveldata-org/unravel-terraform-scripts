output "data_exchange_name" {
  description = "The resource name of the private data exchange."
  value       = google_bigquery_analytics_hub_data_exchange.exchange.name
}

output "data_exchange_id" {
  description = "The ID of the private data exchange."
  value       = google_bigquery_analytics_hub_data_exchange.exchange.data_exchange_id
}

output "listing_names" {
  description = "Listing resource names keyed by listing ID."
  value       = { for key, listing in google_bigquery_analytics_hub_listing.dataset : key => listing.name }
}

output "listing_ids" {
  description = "Listing IDs keyed by listing ID."
  value       = { for key, listing in google_bigquery_analytics_hub_listing.dataset : key => listing.listing_id }
}
