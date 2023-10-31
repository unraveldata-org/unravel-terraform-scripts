#Specify the compatible terraform version
terraform {
  required_version = ">= 1.0.2"
}

# Validating the project ids provided by the user before next steps
data "google_project" "project" {

  for_each = local.project_ids_map

  project_id = each.value

}

# Generates a random integer used to name the resources to be unique
resource "random_integer" "unique_id" {
  max = 5000
  min = 1
}

# Create topics for Unravel Bigquery with Push/Pull subscription
module "unravel_topics" {

  count = var.polling_mode == "schema" ? 0 : 1

  source = "./modules/pubsub"

  project_ids           = var.monitoring_project_ids
  unravel_push_endpoint = var.unravel_push_endpoint
  unravel_pubsub_topic  = "${var.unravel_pubsub_topic}-${random_integer.unique_id.id}"
  pull_model            = local.pull_model

  depends_on = [
  data.google_project.project, module.google_enable_api]

}

# Create roles, service account and associated private keys
module "unravel_iam" {

  source = "./modules/iam"

  project_ids                         = local.project_ids_map
  billing_project_id                  = var.billing_project_id
  datapage_project_ids                = var.datapage_project_ids
  role_permission                     = local.role_permission
  admin_project_ids                   = local.admin_project_ids_map
  admin_project_role_permission       = local.admin_project_role_permission
  billing_project_role_permission     = local.billing_project_role_permission
  monitoring_project_ids              = var.monitoring_project_ids
  billing_unravel_role                = var.billing_unravel_role
  unravel_role                        = "${var.unravel_role}_${random_integer.unique_id.id}"
  admin_unravel_role                  = "${var.admin_unravel_role}_${random_integer.unique_id.id}"
  unravel_service_account             = "${var.unravel_service_account}-${random_integer.unique_id.id}"
  unravel_project_id                  = var.unravel_project_id
  key_based_auth_model                = var.key_based_auth_model
  multi_key_auth_model                = var.multi_key_auth_model
  unravel_keys_location               = var.unravel_keys_location
  admin_only_project_ids_map          = local.admin_only_project_ids_map
  admin_and_monitoring_project_id_map = local.admin_and_monitoring_project_id_map

  depends_on = [
  data.google_project.project, module.google_enable_api]

}


# Create a log router sink with Unravel Pubsub topic as destination
module "unravel_sink" {

  count = var.polling_mode == "schema" ? 0 : 1

  source = "./modules/log_router"

  project_ids       = local.project_ids_map
  sink_filter       = local.sink_filter
  pub_sub_ids       = module.unravel_topics[0].pubsub_ids
  unravel_sink_name = "${var.unravel_sink_name}-${random_integer.unique_id.id}"

  depends_on = [module.google_enable_api]

}

# Attach Pub/Sub Publisher policy to Unravel topic
resource "google_pubsub_topic_iam_policy" "policy" {

  for_each = var.polling_mode == "schema" ? {} : local.project_ids_map

  project     = module.unravel_topics[0].pubsub_ids[each.value].project
  topic       = module.unravel_topics[0].pubsub_ids[each.value].name
  policy_data = data.google_iam_policy.pubsub_access[each.value].policy_data

}

# Enable GCP service API
module "google_enable_api" {

  source = "./modules/apis"

  project_all  = compact(concat(local.monitoring_projects, [var.unravel_project_id]))
  service_apis = local.apis

  depends_on = [
  data.google_project.project]

}

# Enable GCP service API
module "google_enable_admin_api" {

  source = "./modules/apis"

  project_all  = var.admin_project_ids
  service_apis = local.admin_apis

  depends_on = [
  data.google_project.project]

}

# Pub/sub Publisher policy data
data "google_iam_policy" "pubsub_access" {

  for_each = var.polling_mode == "schema" ? {} : local.project_ids_map

  binding {
    role = "roles/pubsub.publisher"

    members = [
      module.unravel_sink[0].sinks[each.value].writer_identity
    ]
  }
}

# Enable google pupsub apis if not already enabled.
resource "google_project_service" "cloud_pubsub_api_unravel" {

  count = var.multi_key_auth_model || var.polling_mode == "schema" ? 0 : 1

  project = var.unravel_project_id
  service = "pubsub.googleapis.com"

  timeouts {
    create = "4m"
    update = "4m"
  }

  # Note: Terraform will not disable the api during destroy.
  # This is to ensure that other systems using this api is not effected.
  disable_on_destroy         = false
  disable_dependent_services = false
}





