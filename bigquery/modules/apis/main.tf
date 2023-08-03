locals {
  # A map of Project id and APIs
  config_apis = distinct(flatten([
    for each_project in var.project_all : [
      for apis in var.service_apis : {
        project_id = each_project
        api_name   = apis
      }
    ]
  ]))
}

# Enable resource manager API
resource "google_project_service" "enable_api" {
  for_each = { for entry in local.config_apis : "${entry.api_name}.${entry.project_id}" => entry }

  project = each.value.project_id
  service = each.value.api_name

  # Note: Terraform will not disable the api during destroy.
  # This is to ensure that other systems using this api is not effected.
  disable_dependent_services = true
  disable_on_destroy         = false

}

