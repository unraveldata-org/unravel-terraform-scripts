
# List of Pub/Sub topic created with attributes
output "pubsub_ids" {
  value = google_pubsub_topic.unravel_topic
}

# List of Push Subscription created with attributes
output "subscriptions" {
  value = google_pubsub_subscription.unravel_subscription
}
