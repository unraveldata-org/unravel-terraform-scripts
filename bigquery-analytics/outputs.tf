output "data_exchange_name" {
  description = "The resource name of the BigQuery Analytics Hub Data Exchange."
  value       = google_bigquery_analytics_hub_data_exchange.clean_room.name
}

output "data_exchange_id" {
  description = "The ID of the Data Exchange."
  value       = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
}

output "listing_name" {
  description = "The resource name of the Analytics Hub Listing."
  value       = google_bigquery_analytics_hub_listing.unravel_listing.name
}

output "listing_id" {
  description = "The ID of the Listing."
  value       = google_bigquery_analytics_hub_listing.unravel_listing.listing_id
}

output "subscription_name" {
  description = "The resource name of the Data Exchange subscription."
  value       = google_bigquery_analytics_hub_data_exchange_subscription.unravel_sub.name
}

output "subscription_id" {
  description = "The ID of the Data Exchange subscription."
  value       = google_bigquery_analytics_hub_data_exchange_subscription.unravel_sub.subscription_id
}

output "destination_dataset" {
  description = "The destination dataset of the subscription."
  value       = google_bigquery_analytics_hub_data_exchange_subscription.unravel_sub.destination_dataset
}
