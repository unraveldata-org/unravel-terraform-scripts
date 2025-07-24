output "cloud_run_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.bq_function.uri
}

output "dlp_deidentify_template_full_path" {
  value = null_resource.dlp_templates.triggers.dlp_de_id_template_full_path
}

output "dlp_inspect_template_full_path" {
  value = null_resource.dlp_templates.triggers.dlp_inspect_template_full_path
}

