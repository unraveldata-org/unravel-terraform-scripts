variable "project_id" {
  description = "The publisher project containing the exchange and existing shared datasets."
  type        = string
}

variable "location" {
  description = "The BigQuery location of the exchange and source datasets (for example, US or EU)."
  type        = string
  default     = "US"
}

variable "data_exchange_id" {
  description = "The ID and display name of the private data exchange."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.data_exchange_id))
    error_message = "data_exchange_id must contain only ASCII letters, numbers, and underscores."
  }
}

variable "primary_contact" {
  description = "The contact email or URL for the exchange and listings."
  type        = string
}

variable "listings" {
  description = "One listing per existing dataset. Each listing shares the entire dataset, including future tables."
  type = list(object({
    listing_id        = string
    source_dataset_id = string
  }))
  nullable = false

  validation {
    condition     = length(distinct([for listing in var.listings : listing.listing_id])) == length(var.listings)
    error_message = "Each listing_id must be unique."
  }

  validation {
    condition = alltrue([
      for listing in var.listings :
      can(regex("^[A-Za-z0-9_]+$", listing.listing_id)) &&
      can(regex("^[A-Za-z0-9_]+$", listing.source_dataset_id))
    ])
    error_message = "Listing IDs and source dataset IDs must contain only ASCII letters, numbers, and underscores."
  }
}

variable "subscriber_members" {
  description = "Explicit IAM members allowed to subscribe to all listings: user:EMAIL or serviceAccount:EMAIL. An empty set removes managed subscriber grants."
  type        = set(string)
  nullable    = false

  validation {
    condition = alltrue([
      for member in var.subscriber_members :
      can(regex("^user:[^:@[:space:]]+@[^:@[:space:]]+\\.[^:@[:space:]]+$", member)) ||
      can(regex("^serviceAccount:[^:@[:space:]]+@[^:@[:space:]]+\\.gserviceaccount\\.com$", member))
    ])
    error_message = "Use user:EMAIL or serviceAccount:EMAIL IAM members. Service accounts must use a gserviceaccount.com address; public principals, groups, and unprefixed emails are not allowed."
  }
}
