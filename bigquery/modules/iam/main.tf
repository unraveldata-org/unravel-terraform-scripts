
locals {

  all_project_ids = merge(var.project_ids, var.admin_project_ids)
  unravel_project_id = { for project in toset([var.unravel_project_id]) : project => project }
}

# Custom IAM role for Unravel
resource "google_project_iam_custom_role" "unravel_role" {

  for_each = var.multi_key_auth_model ? var.project_ids : merge(var.project_ids, local.unravel_project_id)

  project     = each.value
  role_id     = var.unravel_role
  title       = "Unravel Bigquery Role"
  description = "Unravel Bigquery Role to grant access to Read permissions in Bigquery projects"
  permissions = var.role_permission
}

# Custom IAM role for GCP admin project account
resource "google_project_iam_custom_role" "admin_project_unravel_role" {

  for_each = var.admin_project_ids

  project     = each.value
  role_id     = var.admin_unravel_role
  title       = "Unravel Admin Bigquery Role"
  description = "Unravel Bigquery Role for Admin projects with reservations/collections"
  permissions = var.admin_project_role_permission
}

# New service account for Unravel
resource "google_service_account" "unravel_service_account" {

  count = var.multi_key_auth_model ? 0 : 1

  project      = var.unravel_project_id
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.unravel_role]
}

# New service account for Unravel
resource "google_service_account" "project_service_account" {

  for_each = var.multi_key_auth_model ? var.project_ids: {}

  project      = each.value
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.unravel_role]
}

# New service account for Unravel
resource "google_service_account" "admin_service_account" {

  for_each = var.multi_key_auth_model ? var.admin_project_ids : {}

  project      = each.value
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.admin_project_unravel_role]
}

# Attach Project IAM role with Unravel Service account
resource "google_project_iam_member" "project_iam" {

  for_each = var.multi_key_auth_model ? var.project_ids : {}

  project = each.value
  role    = google_project_iam_custom_role.unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.project_service_account[each.value].email}"
}

# Attach Project IAM role with Unravel Service account
resource "google_project_iam_member" "admin_unravel_iam" {

  for_each = var.multi_key_auth_model ? var.admin_project_ids : {}

  project = each.value
  role    = google_project_iam_custom_role.admin_project_unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.admin_service_account[each.value].email}"

}

# Attach Project IAM role with Unravel Service account
resource "google_project_iam_member" "unravel_iam" {

  for_each = var.multi_key_auth_model ? {} : merge(var.project_ids, local.unravel_project_id)

  project = each.value
  role    = google_project_iam_custom_role.unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.unravel_service_account[0].email}"
}

# Generate base64 encoded key for Unravel service account
resource "google_service_account_key" "project_key" {

  for_each = var.multi_key_auth_model ? var.project_ids : {}

  service_account_id = google_service_account.project_service_account[each.value].name

  depends_on = [google_project_iam_member.unravel_iam]
}

# Generate base64 encoded key for Unravel service account
resource "google_service_account_key" "admin_unravel_key" {

  for_each = var.multi_key_auth_model ? var.admin_project_ids : {}

  service_account_id = google_service_account.admin_service_account[each.value].name

  depends_on = [google_project_iam_member.admin_unravel_iam]
}

# Generate base64 encoded key for Unravel service account
resource "google_service_account_key" "unravel_key" {

  count = var.key_based_auth_model ? 1 : 0

  service_account_id = google_service_account.unravel_service_account[0].name

  depends_on = [google_project_iam_member.unravel_iam]
}