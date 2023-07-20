variable "project_ids" {
  description = "List of projects ids from input.tfvars file in key value pair"
  default     = {}
}

variable "sink_filter" {
  description = "Sink filter rules as defined in locals variable"
  default     = ""
}

variable "pub_sub_ids" {
  description = "Pub/sub Ids created by terraform"
  default     = []
}

variable "unravel_sink_name" {
  description = "Sink filter rules as defined in locals variable"
  default     = ""
}
