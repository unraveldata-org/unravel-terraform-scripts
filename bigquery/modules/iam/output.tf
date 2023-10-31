
# Service account Key
output "keys" {
  value = var.key_based_auth_model ? google_service_account_key.unravel_key[0] : null
}

# Service account created and it's attributes
output "unravel_service_account" {
  value = var.multi_key_auth_model ? null : google_service_account.multi_key_project_service_accounts[var.unravel_project_id]
}

# IAM roles created and it's attributes
output "project_iam_role" {
  value = google_project_iam_custom_role.unravel_role
}

# Service accounts created for projects when multi auth mode is eanbled
output "multi_key_project_service_accounts" {
  value = var.multi_key_auth_model ? google_service_account.multi_key_project_service_accounts : null
}

output "multi_key_project_binding" {
  value = var.multi_key_auth_model ? google_project_iam_member.multi_key_project_unravel_iam : null
}

output "admin_project_unravel_role" {
  value = google_project_iam_custom_role.admin_project_unravel_role
}

output "multi_key_admin_service_accounts" {
  value = var.multi_key_auth_model ? google_service_account.multi_key_admin_service_accounts : null
}

output "admin_unravel_iam" {
  value = var.multi_key_auth_model ? null : google_project_iam_member.admin_unravel_iam
}

output "multi_key_admin_binding" {
  value = var.multi_key_auth_model ? google_project_iam_member.multi_key_admin_unravel_iam : null
}

output "unravel_binding" {
  value = var.multi_key_auth_model ? null : google_project_iam_member.unravel_iam
}

output "admin_only_project_binding" {
  value = google_project_iam_member.multi_key_admin_unravel_iam
}

output "admin_and_monitoring_project_binding" {
  value = google_project_iam_member.multi_key_admin_n_project_unravel_iam
}

output "billing_project_role" {
  value = contains(keys(var.monitoring_project_ids), var.billing_project_id) || var.billing_project_id == "" ? null: google_project_iam_custom_role.billing_project_unravel_role
}

output "multi_billing_service_account" {
  value = contains(keys(var.monitoring_project_ids), var.billing_project_id) || var.billing_project_id == "" ? null: google_service_account.multi_key_billing_service_accounts
}

output "multi_key_billing_unravel_iam" {
  value = contains(keys(var.monitoring_project_ids), var.billing_project_id) || var.billing_project_id == "" ? null: google_project_iam_member.multi_key_billing_unravel_iam
}
