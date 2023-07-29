
# Service account Key
output "keys" {
  value = var.key_based_auth_model ? google_service_account_key.unravel_key: null
}

# Service account Key
output "project_keys" {
  value = var.multi_key_auth_model ? google_service_account_key.project_key : null
}

# Service account Key
output "admin_keys" {
  value = var.multi_key_auth_model ? google_service_account_key.admin_unravel_key : null
}

# Service account created and it's attributes
output "service_account" {
  value = google_service_account.unravel_service_account
}

# Service account created and it's attributes
output "monitoring_service_account" {
  value = google_service_account.project_service_account
}

# Service account created and it's attributes
output "admin_service_account" {
  value = google_service_account.admin_service_account
}

# IAM roles created and it's attributes
output "iam_role" {
  value = google_project_iam_custom_role.unravel_role
}

# IAM roles created for admin accounts
output "admin_iam_role" {
  value = google_project_iam_custom_role.admin_project_unravel_role
}

output "admin_binding" {
  value = google_project_iam_member.admin_unravel_iam
}

output "project_binding" {
  value = google_project_iam_member.project_iam
}

output "unravel_binding" {
  value = var.key_based_auth_model ? {} : google_project_iam_member.unravel_iam
}