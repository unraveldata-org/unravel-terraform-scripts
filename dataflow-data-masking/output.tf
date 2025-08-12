output "dataflow_job_name" {
  description = "The name of the Dataflow job."
  value       = google_dataflow_job.dlp_deid_job.name
}

output "dataflow_job_id" {
  description = "The ID of the Dataflow job."
  value       = google_dataflow_job.dlp_deid_job.job_id
}

