# Custom IAM role for Unravel

locals {
  unravel_project_id = var.multi_key_auth_model ? {} : { for project in toset([var.unravel_project_id]) : project => project }
  all_project_ids    = var.multi_key_auth_model ? var.project_ids : merge(var.project_ids, local.unravel_project_id)

}

### Monitoring Projects ###

# Create IAM Roles for all monitoring projects
resource "google_project_iam_custom_role" "unravel_role" {

  for_each = local.all_project_ids

  project     = each.value
  role_id     = var.unravel_role
  title       = "Unravel Bigquery Role"
  description = "Unravel Bigquery Role to grant access to Read permissions in Bigquery projects"
  permissions = var.role_permission
}

# Create Service accounts for all Monitoring projects if Multi Key auth is enabled
resource "google_service_account" "multi_key_project_service_accounts" {

  for_each     = var.multi_key_auth_model ? local.all_project_ids : {}
  project      = each.value
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.unravel_role]
}

# Attach Project IAM roles with respective Project Service account if Multi Key Auth Model is enabled
resource "google_project_iam_member" "multi_key_project_unravel_iam" {

  for_each = var.multi_key_auth_model ? local.all_project_ids : {}

  project = each.value
  role    = google_project_iam_custom_role.unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.multi_key_project_service_accounts[each.value].email}"
}

# Generate base64 encoded key for service accounts in all Monitoring projects if Multi Key based model is enabled
resource "google_service_account_key" "project_unravel_key" {

  for_each = var.multi_key_auth_model ? local.all_project_ids : {}

  service_account_id = google_service_account.multi_key_project_service_accounts[each.value].name

  depends_on = [google_project_iam_member.multi_key_project_unravel_iam]
}

# Write decoded Service account private keys to filesystem
resource "local_file" "project_keys" {

  for_each = var.multi_key_auth_model ? local.all_project_ids : {}

  content  = base64decode(google_service_account_key.project_unravel_key[each.value].private_key)
  filename = "${var.unravel_keys_location}/${each.value}.json"

}
##########################

### Admin Projects ###

# Custom IAM role for GCP admin project accounts
resource "google_project_iam_custom_role" "admin_project_unravel_role" {

  for_each = var.admin_project_ids

  project     = each.value
  role_id     = var.admin_unravel_role
  title       = "Unravel Admin Bigquery Role"
  description = "Unravel Bigquery Role for Admin projects with reservations/collections"
  permissions = var.admin_project_role_permission
}

# Creates service account for all Admin projects if Multi Key based auth model is enabled
resource "google_service_account" "multi_key_admin_service_accounts" {

  for_each     = var.multi_key_auth_model ? var.admin_only_project_ids_map : {}
  project      = each.value
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.admin_project_unravel_role]
}


# Attach Project IAM role with respective Service accounts in each Admin project if Multi key auth model is enabled
resource "google_project_iam_member" "multi_key_admin_unravel_iam" {

  for_each = var.multi_key_auth_model ? var.admin_only_project_ids_map : {}

  project = each.value
  role    = google_project_iam_custom_role.admin_project_unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.multi_key_admin_service_accounts[each.value].email}"
}

# Attach Project IAM role with respective Service accounts in each Admin project if Multi key auth model is enabled
resource "google_project_iam_member" "multi_key_admin_n_project_unravel_iam" {

  for_each = var.multi_key_auth_model ? var.admin_and_monitoring_project_id_map : {}

  project = each.value
  role    = google_project_iam_custom_role.admin_project_unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.multi_key_project_service_accounts[each.value].email}"
}


# Generate base64 encoded key for Unravel service account
resource "google_service_account_key" "admin_unravel_key" {

  for_each = var.multi_key_auth_model ? var.admin_only_project_ids_map : {}

  service_account_id = google_service_account.multi_key_admin_service_accounts[each.value].name

  depends_on = [google_project_iam_member.multi_key_admin_unravel_iam]
}

# Write decoded Service account private keys to filesystem
resource "local_file" "admin_keys" {

  for_each = var.multi_key_auth_model ? var.admin_only_project_ids_map : {}

  content  = base64decode(google_service_account_key.admin_unravel_key[each.value].private_key)
  filename = "${var.unravel_keys_location}/${each.value}.json"

}

#################

### Unravel Project and single/vm based ###

# New service account for Unravel
resource "google_service_account" "unravel_service_account" {

  count = var.multi_key_auth_model ? 0 : 1

  project      = var.unravel_project_id
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.unravel_role]
}

# Attach Project IAM role with Unravel Service account
resource "google_project_iam_member" "unravel_iam" {

  for_each = var.multi_key_auth_model ? {} : local.all_project_ids


  project = each.value
  role    = google_project_iam_custom_role.unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.unravel_service_account[0].email}"
}


resource "google_project_iam_member" "admin_unravel_iam" {

  for_each = var.multi_key_auth_model ? {} : var.admin_project_ids

  project = each.value
  role    = google_project_iam_custom_role.admin_project_unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.unravel_service_account[0].email}"
}

# Generate base64 encoded key for Unravel service account
resource "google_service_account_key" "unravel_key" {

  count = var.key_based_auth_model ? 1 : 0

  service_account_id = google_service_account.unravel_service_account[0].name

  depends_on = [google_project_iam_member.unravel_iam]
}

# Write decoded Service account private keys to filesystem
resource "local_file" "unravel_keys" {

  count = var.key_based_auth_model ? 1 : 0

  content  = base64decode(google_service_account_key.unravel_key[0].private_key)
  filename = "${var.unravel_keys_location}/${var.unravel_project_id}.json"

}

#######################