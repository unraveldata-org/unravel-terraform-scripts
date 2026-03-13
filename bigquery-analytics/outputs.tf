output "data_exchange_name" {
  description = "The resource name of the BigQuery Analytics Hub Data Exchange."
  value       = google_bigquery_analytics_hub_data_exchange.clean_room.name
}

output "data_exchange_id" {
  description = "The ID of the Data Exchange."
  value       = google_bigquery_analytics_hub_data_exchange.clean_room.data_exchange_id
}