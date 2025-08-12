variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region to deploy the Dataflow job."
  type        = string
}

variable "template_gcs_path" {
  description = "GCS path to the Dataflow job template."
  type        = string
}

variable "temp_gcs_location" {
  description = "GCS location for temporary files."
  type        = string
}

variable "input_project_ids" {
  description = "Comma-separated list of input project IDs."
  type        = string
}

variable "input_table" {
  description = "BigQuery input table in <dataset>.<table> format."
  type        = string
}

variable "output_table" {
  description = "BigQuery output table in <project>.<dataset>.<table> format."
  type        = string
}

