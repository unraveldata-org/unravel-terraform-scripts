# Custom IAM role for Unravel

locals {
  all_project_ids = var.project_ids

}

### Monitoring Projects ###

# Create IAM Roles for all monitoring projects
resource "google_project_iam_custom_role" "unravel_role" {

  for_each = var.project_ids

  project     = each.value
  role_id     = var.unravel_role
  title       = "Unravel Bigquery Role"
  description = "Unravel Bigquery Role to grant access to Read permissions in Bigquery projects"
  permissions = var.role_permission
}


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

### Unravel Project and single/vm based ###

# Attach Project IAM role with Unravel Service account
resource "google_project_iam_member" "unravel_iam" {

  for_each = var.project_ids


  project = each.value
  role    = google_project_iam_custom_role.unravel_role[each.value].name
  member  = var.unravel_service_account
}


resource "google_project_iam_member" "admin_unravel_iam" {

  for_each = var.admin_project_ids

  project = each.value
  role    = google_project_iam_custom_role.admin_project_unravel_role[each.value].name
  member  = var.unravel_service_account
}



