variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The region in which to provision resources."
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "The location for the Data Exchange and Listing (e.g., US, EU)."
  type        = string
  default     = "US"
}

variable "data_exchange_id" {
  description = "The ID of the BigQuery Analytics Hub Data Exchange."
  type        = string
}

variable "data_exchange_display_name" {
  description = "The display name of the Data Exchange."
  type        = string
}

variable "primary_contact" {
  description = "The primary contact email for the Data Exchange."
  type        = string
}

variable "source_dataset_id" {
  description = "The ID of the existing dataset to be shared."
  type        = string
}

variable "listing_id" {
  description = "The ID of the Analytics Hub Listing."
  type        = string
}

variable "listing_display_name" {
  description = "The display name of the Listing."
  type        = string
}

variable "shared_table_ids" {
  description = "The list of full resource names of the tables to share (e.g., projects/my-project/datasets/my-dataset/tables/my-table)."
  type        = list(string)
}

variable "subscriber_email" {
  description = "The email of the user to grant subscriber permissions to."
  type        = string
}

variable "subscription_id" {
  description = "The ID of the Data Exchange subscription."
  type        = string
}

variable "destination_dataset_id" {
  description = "The ID of the dataset where the subscription will be created."
  type        = string
}
