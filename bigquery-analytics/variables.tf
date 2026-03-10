# ==========================================
# Google Cloud Project Configuration
# ==========================================

variable "project_id" {
  description = "The GCP Project ID where the Data Exchange and Listing will be created (the Publisher project)."
  type        = string
}

variable "region" {
  description = "The GCP region for the dataset and Analytics Hub resources (e.g., US)."
  type        = string
  default     = "US"
}

# ==========================================
# Data Exchange & Listing Configuration
# ==========================================

variable "data_exchange_id" {
  description = "A unique ID for the Analytics Hub Data Exchange. If you get a 409 Conflict, change this ID."
  type        = string
  default     = "shared_data_unravel"
}

variable "data_exchange_display_name" {
  description = "The human-readable name for the Clean Room shown in the GCP Console."
  type        = string
  default     = "Unravel Data Share Clean Room"
}

variable "primary_contact_email" {
  description = "The email address of the person managing this Data Exchange (usually your admin email)."
  type        = string
}

variable "log_linked_dataset_query_user_email" {
  description = "If true, Google will log the email address of every user who queries the shared data. Once enabled, this cannot be turned off."
  type        = bool
  default     = true
}

# ==========================================
# Access Control (Unravel)
# ==========================================

variable "unravel_principal_email" {
  description = "The Unravel Service Account provided to you (e.g., serviceAccount:sa-name@unravel-data.iam.gserviceaccount.com)."
  type        = string
}

# ==========================================
# Automated Subscription Configuration
# ==========================================

variable "enable_subscription" {
  description = "Set to true to automatically 'accept' the listing and create a linked dataset in the subscriber project."
  type        = bool
  default     = false
}

variable "subscriber_project_id" {
  description = "The Project ID where the subscription (linked dataset) will be created. Often the same as project_id for testing."
  type        = string
  default     = ""
}

variable "destination_dataset_id" {
  description = "The ID for the new linked dataset created in the subscriber project."
  type        = string
  default     = "unravel_shared_metadata"
}
