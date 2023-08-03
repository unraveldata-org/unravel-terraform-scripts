variable "project_all" {
  description = "List of projects ids from input.tfvars file in key value pair"
  type        = list(string)
  default     = []
}

variable "service_apis" {
  description = "Name of the api that has to be enabled"
  type        = list(string)
  default     = []
}

