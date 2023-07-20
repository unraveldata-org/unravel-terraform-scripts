
# Custom IAM role for Unravel
resource "google_project_iam_custom_role" "unravel_role" {

  for_each = var.project_ids

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

  project      = var.unravel_project_id
  account_id   = var.unravel_service_account
  display_name = "Unravel Bigquery Service Account"

  depends_on = [google_project_iam_custom_role.unravel_role]
}

# Attach Project IAM role with Unravel Service account
resource "google_project_iam_member" "unravel_iam" {

  for_each = var.project_ids

  project = each.value
  role    = google_project_iam_custom_role.unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.unravel_service_account.email}"
}


# Attach Admin IAM role with Unravel Service account in Admin projects
resource "google_project_iam_member" "admin_unravel_iam" {

  for_each = var.admin_project_ids

  project = each.value
  role    = google_project_iam_custom_role.admin_project_unravel_role[each.value].name
  member  = "serviceAccount:${google_service_account.unravel_service_account.email}"
}

# Generate base64 encoded key for Unravel service account
resource "google_service_account_key" "unravel_key" {

  count = var.key_based_auth_model ? 1 : 0

  service_account_id = google_service_account.unravel_service_account.name

  depends_on = [google_project_iam_member.unravel_iam]
}