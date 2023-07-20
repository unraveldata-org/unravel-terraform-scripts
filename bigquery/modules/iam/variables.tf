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
  description = "Key-based authorization flag"
  type        = bool
  default     = false
}
