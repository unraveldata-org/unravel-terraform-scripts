variable "project_ids" {
  description = "List of projects ids from input.tfvars file in key value pair"
  type        = map(string)
  default     = {}
}

variable "role_permission" {
  description = "List of role permissions from local variables"
  default     = []
}

variable "admin_project_role_permission" {
  description = "List of admin project role permissions from local variables"
  default     = []
}

variable "admin_project_ids" {
  description = "List of admin projects ids from input.tfvars file in key value pair"
  type        = map(string)
  default     = {}
}

variable "unravel_role" {
  description = "Unravel custom role name"
  default     = ""
}

variable "admin_unravel_role" {
  description = "Unravel custom role name for Admin accounts"
  default     = ""
}

variable "unravel_service_account" {
  description = "Unravel service account name"
  default     = ""
}

variable "unravel_project_id" {
  type        = string
  description = "Project id where Unravel is running"
}

variable "key_based_auth_model" {
  description = "Key-based authentication flag"
  type        = bool
  default     = false
}

variable "multi_key_auth_model" {
  description = "Multi key based authentication flag"
  type        = bool
}

variable "unravel_keys_location" {
  description = "Local Filesystem location to write the files"
  type        = string
  default     = "./keys"
}

variable "admin_only_project_ids_map" {
  type    = map(string)
  default = {}

}
variable "admin_and_monitoring_project_id_map" {
  type    = map(string)
  default = {}
}

variable "billing_project_id" {}
variable "datapage_project_ids" {}
variable "billing_project_role_permission" {}
variable "billing_unravel_role" {}
variable "monitoring_project_ids" {}