variable "pull_model" {
  description = "Enables Pull model for PubSub topic"
  type        = bool

  default = true
}

variable "project_ids" {
  description = "GCP Project IDs for configuring Unravel Bigquery. Only those queries running in these projects will be monitored"
  type        = list(string)

  validation {
    condition = length([
      for project in var.project_ids : true
      if can(regex("[a-z0-9-]+$", project))
    ]) == length(var.project_ids)
    error_message = "Accepts only GCP project ID and not Project Name. Please provide a valid GCP project ID. Ex: 'tactical-factor-123456'."
  }

  validation {
    condition     = length(var.project_ids) == length(distinct(var.project_ids))
    error_message = "All project ids must be unique."
  }
}

variable "unravel_push_endpoint" {
  description = "Publicly accessible HTTPS Unravel LR endpoint"
  type        = string

  validation {
    condition     = can(regex("https://[a-z0-9-._A-Z]+(:[0-9]{2,})?$", var.unravel_push_endpoint))
    error_message = "Unravel Push endpoint should be a valid publicly accessible HTTPS endpoint without a trailing '/'. Ex: 'https://bigquery.unraveldata.com'."
  }

  default = "https://devnull.unraveldata.unravel"

}

variable "unravel_project_id" {
  description = "ID of the GCP Project where Unravel VM  is running"
  type        = string

  validation {
    condition     = can(regex("[a-zA-Z0-9-]+$", var.unravel_project_id))
    error_message = "Accepts only a valid project name. Please provide a valid project name."
  }
}

variable "admin_project_ids" {
  description = "GCP Admin Project IDs where reservations/collections are configured"
  type        = list(string)

  validation {
    condition = length([
      for project in var.admin_project_ids : true
      if can(regex("[a-z0-9-]+$", project))
    ]) == length(var.admin_project_ids)
    error_message = "Accepts only GCP project ID and not Project Name. Please provide a valid GCP project ID. Ex: 'tactical-factor-123456'."
  }

  validation {
    condition     = length(var.admin_project_ids) == length(distinct(var.admin_project_ids))
    error_message = "All project ids must be unique."
  }

  default = []

}

# **Optional Variables/Variables with Default Values**

variable "unravel_keys_location" {
  description = "Local FS path to save GCP service account Keys"
  type        = string

  default = "./keys"

  validation {
    condition     = can(regex("[a-z0-9-._/A-Z]+[A-Za-z0-9]$", var.unravel_keys_location))
    error_message = "A valid filesystem path where unravel user have access to without a trailing '/'. Ex: './keys' ."
  }
}

variable "unravel_push_subscription" {

  description = "Unravel Pub/Sub topic subscription ID"
  type        = string

  default = "unravel_subscription"

  validation {
    condition     = can(regex("^[a-zA-Z][A-Z0-9a-z-~%+_.]{2,}$", var.unravel_push_subscription))
    error_message = "ID must start with a letter, and contain only the following characters: letters, numbers, dashes (-), periods (.), underscores (_), tildes (~), percents (%) or plus signs (+). Cannot start with goog."
  }
}

variable "unravel_pubsub_topic" {

  description = "Unravel Pub/Sub topic name"
  type        = string

  default = "unravel_topic"

  validation {
    condition     = can(regex("^[a-zA-Z][A-Z0-9a-z~%+_.-]{2,}$", var.unravel_pubsub_topic))
    error_message = "ID must start with a letter, and contain only the following characters: letters, numbers, dashes (-), periods (.), underscores (_), tildes (~), percents (%) or plus signs (+). Cannot start with goog."
  }
}


variable "unravel_role" {
  description = "Custom role name for Unravel"
  type        = string

  default = "unravel_role"

  validation {
    condition     = can(regex("^[a-z0-9_.]{3,64}$", var.unravel_role))
    error_message = "ID must start with a letter, and contain only the following characters: letters, numbers, dashes (-)."
  }
}

variable "admin_unravel_role" {
  description = "Custom role name for GCP Admin accounts"
  type        = string

  default = "admin_unravel_role"

  validation {
    condition     = can(regex("^[a-z0-9_.]{3,64}$", var.admin_unravel_role))
    error_message = "ID must start with a letter, and contain only the following characters: letters, numbers, dashes (-)."
  }
}

variable "unravel_sink_name" {
  description = "Sink name for Unravel"
  type        = string

  default = "unravel_pubsub_sink"

  validation {
    condition     = can(regex("^[a-zA-Z][-_a-z0-9]+[a-z0-9]$", var.unravel_sink_name))
    error_message = "ID must start with a letter, and contain only the following characters: letters, numbers, dashes (-)."
  }
}

variable "unravel_service_account" {
  description = "Service account name for Unravel"
  type        = string

  default = "unravel-svc-account"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.unravel_service_account))
    error_message = "ID must start with a letter, and contain only the following characters: letters, numbers, dashes (-) and should have atleast 6 characters."
  }

}

variable "key_based_auth_model" {
  description = "Enable or disable the key-based authentication model"
  type        = bool
  default     = false
}

variable "x_svc_acc_permissions" {
  description = "List of extended service account permissions required for Unravel VM"
  type        = list(string)
  default     = ["logging.logEntries.create"]
}
