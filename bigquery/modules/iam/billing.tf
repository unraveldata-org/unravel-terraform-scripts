
### Billing Projects ###
locals {
#  billing_only_project_map       = { for project in toset(local.billing_only_project) : project => project }
  billing_only_project = contains(keys(var.monitoring_project_ids), var.billing_project_id) || var.billing_project_id == "" ? [] : [
    var.billing_project_id
  ]
  billing_only_project_map       = { for project in toset(local.billing_only_project) : project => project }
}



# Custom IAM role for GCP billing project accounts
resource "google_project_iam_custom_role" "billing_project_unravel_role" {

  for_each  =  length(local.billing_only_project) > 0 ? local.billing_only_project_map : {}
#  count = length(local.billing_only_project) > 0 ? 1 : 0


  project     = each.value
  role_id     = var.billing_unravel_role
  title       = "Unravel Billing  Role"
  description = "Unravel Role for Billing project with reservations/collections"
  permissions = var.billing_project_role_permission
}

# Creates service account for all Billing projects if Multi Key based auth model is enabled
resource "google_service_account" "multi_key_billing_service_accounts" {


#  count = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? 1 : 0
 
  for_each = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? local.billing_only_project_map : {}
  project      = local.billing_only_project_map[each.value]
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.billing_project_unravel_role]
}

# Attach Project IAM role with respective Service accounts in each Admin project if Multi key auth model is enabled
resource "google_project_iam_member" "multi_key_billing_unravel_iam" {

  for_each = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? local.billing_only_project_map : {}

  project = each.value
  role    = google_project_iam_custom_role.billing_project_unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.multi_key_billing_service_accounts[each.value].email}"
}

# Generate base64 encoded key for Admin Unravel service account
resource "google_service_account_key" "billing_unravel_key" {

  for_each = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? local.billing_only_project_map : {}



  service_account_id = google_service_account.multi_key_billing_service_accounts[each.value].name

  depends_on = [google_project_iam_member.multi_key_billing_unravel_iam]
}

# Write decoded Admin Service account private keys to filesystem
resource "local_file" "billing_keys" {

  for_each = var.multi_key_auth_model && (length(local.billing_only_project) > 0) ? local.billing_only_project_map : {}


  content  = base64decode(google_service_account_key.billing_unravel_key[each.value].private_key)
  filename = "${var.unravel_keys_location}/${local.billing_only_project[each.value]}.json"

}

