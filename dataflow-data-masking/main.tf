resource "google_dataflow_job" "dlp_deid_job" {
  name              = local.job_name
  template_gcs_path = var.template_gcs_path
  temp_gcs_location = var.temp_gcs_location
  region            = var.region

  parameters = {
    inputProjectIds = var.input_project_ids
    inputTable      = var.input_table
    outputTable     = var.output_table
  }
}

