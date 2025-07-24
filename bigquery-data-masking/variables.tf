variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "bq_dataset" {
  type    = string
  default = "fns_1"
}

variable "dlp_deid_template_json_file" {
  type    = string
  default = "sample_dlp_deid_config.json"
}

variable "dlp_inspect_template_json_file" {
  type    = string
  default = "sample_dlp_inspect_config.json"
}

variable "service_name" {
  type    = string
  default = "unravel-bq-transform"
}

variable "user_os" {
  type        = string
  default     = "linux"
  description = "The OS of the person running the Terraform script. Options: [linux, darwin]"
  validation {
    condition     = contains(["linux", "darwin"], var.user_os)
    error_message = "Supported OS Options: [linux, darwin]"
  }
}

variable "docker_image" {
  type        = string
  description = "Docker image to use for Cloud Run"
}

