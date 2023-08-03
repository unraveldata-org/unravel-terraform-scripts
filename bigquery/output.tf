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
output "unravel_service_account" {
  value = var.multi_key_auth_model ? null : module.unravel_iam.unravel_service_account
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

