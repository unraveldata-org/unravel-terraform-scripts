
### Billing Projects ###
locals {
  billing_only_project = contains(keys(var.monitoring_project_ids), var.billing_project_id) || var.billing_project_id == "" ? [] : [
    var.billing_project_id
  ]
}



# Custom IAM role for GCP billing project accounts
resource "google_project_iam_custom_role" "billing_project_unravel_role" {

  count = length(local.billing_only_project) > 0 ? 1 : 0


  project     = var.billing_project_id
  role_id     = var.billing_unravel_role
  title       = "Unravel Billing  Role"
  description = "Unravel Role for Billing project with reservations/collections"
  permissions = var.billing_project_role_permission
}

# Creates service account for all Billing projects if Multi Key based auth model is enabled
resource "google_service_account" "multi_key_billing_service_accounts" {

  count = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? 1 : 0


  project      = local.billing_only_project[count.index]
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.billing_project_unravel_role]
}

# Attach Project IAM role with respective Service accounts in each Admin project if Multi key auth model is enabled
resource "google_project_iam_member" "multi_key_billing_unravel_iam" {

  count = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? 1 : 0

  project = local.billing_only_project[count.index]
  role    = google_project_iam_custom_role.billing_project_unravel_role[count.index].name
  member  = "serviceAccount:${google_service_account.multi_key_billing_service_accounts[count.index].email}"
}

# Generate base64 encoded key for Admin Unravel service account
resource "google_service_account_key" "billing_unravel_key" {

  count = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? 1 : 0


  service_account_id = google_service_account.multi_key_billing_service_accounts[count.index].name

  depends_on = [google_project_iam_member.multi_key_billing_unravel_iam]
}

# Write decoded Admin Service account private keys to filesystem
resource "local_file" "billing_keys" {

  count = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? 1 : 0


  content  = base64decode(google_service_account_key.billing_unravel_key[count.index].private_key)
  filename = "${var.unravel_keys_location}/${local.billing_only_project[count.index]}.json"

}

