
# Service account Key
output "keys" {
  value = var.key_based_auth_model ? google_service_account_key.unravel_key[0] : null
}

# Service account created and it's attributes
output "service_account" {
  value = google_service_account.unravel_service_account
}

# IAM roles created and it's attributes
output "iam_role" {
  value = google_project_iam_custom_role.unravel_role
}

