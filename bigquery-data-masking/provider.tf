terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  provider_meta "google" {
    module_name = "cloud-solutions/deploy-bigquery-dlp-remote-function-v0.1"
  }
}

provider "google" {
  billing_project = var.project_id
  project         = var.project_id
  region          = var.region
}

