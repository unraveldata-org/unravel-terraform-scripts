# Log Router Sinks created by terraform
output "sinks" {
  value = module.unravel_sink.sinks
}

# Pub/Sub topics created by terraform
output "pub_sub" {
  value = module.unravel_topics.pubsub_ids
}

# Pub/Sub subscription id created by terraform
output "subscription_id" {
  value = module.unravel_topics.subscriptions
}

# List of API's enabled for the projects
output "api" {
  value = module.google_enable_api.api
}

# Service account created and it's attributes

# IAM roles created and it's attributes
output "project_iam_role" {
  value = module.unravel_iam.project_iam_role
}

output "admin_project_unravel_role" {
  value = module.unravel_iam.admin_project_unravel_role
}

output "admin_unravel_iam" {
  value = module.unravel_iam.admin_unravel_iam
}

output "unravel_binding" {
  value = module.unravel_iam.unravel_binding
}

