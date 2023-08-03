variable "project_ids" {
  description = "List of projects ids from input.tfvars file in key value pair"
  default = {}
}

variable "unravel_push_endpoint" {
  description = "Unravel LR endpoint as provided in the intput.tfvars file"
  default     = ""
}

variable "unravel_subscription" {
  description = "Unravel push subscription as provided in the intput.tfvars file"
  default     = ""
}

variable "unravel_pubsub_topic" {
  description = "Unravel Pub/Sub topic name as provided in the intput.tfvars file"
  default     = ""
}

variable "pull_model" {
  description = "Boolean flag to toggle pull / push model subscription"
  default     = true
}
