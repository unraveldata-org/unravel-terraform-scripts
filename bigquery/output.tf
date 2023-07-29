# Log Router Sinks created by terraform
output "sinks" {
  value = module.unravel_sink.sinks
}

# Pub/Sub topics created by terraform
output "pub_sub" {
  value = module.unravel_topics.pubsub_ids
}

# IAM service accounts created by terraform
output "iam_role" {
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

# Service account created and it's attributes
output "service_account" {
  value = module.unravel_iam.service_account
}

# Service account created and it's attributes
output "monitoring_service_account" {
  value = module.unravel_iam.monitoring_service_account
}

# Service account created and it's attributes
output "admin_service_account" {
  value = module.unravel_iam.admin_service_account
}

# IAM roles created and it's attributes
output "monitoring_am_role" {
  value = module.unravel_iam.iam_role
}

# IAM roles created for admin accounts
output "admin_iam_role" {
  value = module.unravel_iam.admin_iam_role
}

output "admin_binding" {
  value = module.unravel_iam.admin_binding
}

output "project_binding" {
  value = module.unravel_iam.project_binding
}

output "unravel_binding" {
  value = var.key_based_auth_model ? null : module.unravel_iam.unravel_binding
}