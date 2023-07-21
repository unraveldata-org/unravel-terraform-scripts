# Log Router Sinks created by terraform
output "sinks" {
  value = module.unravel_sink.sinks
}

# Pub/Sub topics created by terraform
output "pub_sub" {
  value = module.unravel_topics.pubsub_ids
}

# IAM service accounts created by terraform
output "iam" {
  value = module.unravel_iam.iam_role
}

# Pub/Sub subscription id created by terraform
output "subscription_id" {
  value = module.unravel_topics.subscriptions
}

# List of API's enabled for the projects
output "api" {
  value = module.google_enable_api.api
}