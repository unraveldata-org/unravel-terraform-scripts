



# IAM roles created and it's attributes
output "project_iam_role" {
  value = google_project_iam_custom_role.unravel_role
}


output "admin_project_unravel_role" {
  value = google_project_iam_custom_role.admin_project_unravel_role
}


output "admin_unravel_iam" {
  value = google_project_iam_member.admin_unravel_iam
}


output "unravel_binding" {
  value = google_project_iam_member.unravel_iam
}


