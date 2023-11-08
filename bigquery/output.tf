# Log Router Sinks created by terraform
output "sinks" {
  value = var.polling_mode == "schema" ? null : module.unravel_sink[0].sinks
}

# Pub/Sub topics created by terraform
output "pub_sub" {
  value = var.polling_mode == "schema" ? null : module.unravel_topics[0].pubsub_ids
}

# Pub/Sub subscription id created by terraform
output "subscription_id" {
  value = var.polling_mode == "schema" ? null : module.unravel_topics[0].subscriptions
}

# List of API's enabled for the projects
output "api" {
  value = module.google_enable_api.api
}

# Service account created and it's attributes
output "unravel_service_account" {
  value = var.multi_key_auth_model ? null : module.unravel_iam.unravel_service_account
}

# Path to Unravel Keys location
output "unravel_keys_location" {
  value = var.multi_key_auth_model || var.key_based_auth_model ? var.unravel_keys_location : ""
}

# IAM roles created and it's attributes
output "project_iam_role" {
  value = module.unravel_iam.project_iam_role
}

output "multi_key_project_service_accounts" {
  value = var.multi_key_auth_model ? module.unravel_iam.multi_key_project_service_accounts : null
}

output "multi_key_project_binding" {
  value = var.multi_key_auth_model ? module.unravel_iam.multi_key_project_binding : null
}

output "admin_project_unravel_role" {
  value = module.unravel_iam.admin_project_unravel_role
}

output "multi_key_admin_service_accounts" {
  value = var.multi_key_auth_model ? module.unravel_iam.multi_key_admin_service_accounts : null
}

output "admin_unravel_iam" {
  value = var.multi_key_auth_model ? null : module.unravel_iam.admin_unravel_iam
}

output "multi_key_admin_binding" {
  value = var.multi_key_auth_model ? module.unravel_iam.multi_key_admin_binding : null
}

output "unravel_binding" {
  value = var.multi_key_auth_model ? null : module.unravel_iam.unravel_binding
}

output "admin_only_project_binding" {
  value = var.multi_key_auth_model ? module.unravel_iam.admin_only_project_binding : null
}

output "admin_and_monitoring_project_binding" {
  value = var.multi_key_auth_model ? module.unravel_iam.admin_and_monitoring_project_binding : null
}

