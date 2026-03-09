variable "project_id" {
  description = "The Google Cloud Project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region for the dataset (must be US as per document)."
  type        = string
  default     = "US"
}

variable "unravel_principal_email" {
  description = "The full principal member (e.g., serviceAccount:sa-name@project.iam.gserviceaccount.com or user:email@domain.com) to grant access to."
  type        = string
}

variable "primary_contact_email" {
  description = "The email address of the primary contact for the Clean Room (usually the admin creating it)."
  type        = string
}
