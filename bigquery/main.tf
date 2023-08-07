# Specify the compatible terraform version
terraform {
  required_version = ">= 1.0.2"
}

# Validating the project ids provided by the user before next steps
data "google_project" "project" {

  for_each = local.project_ids_map

  project_id = each.value

}

# Variables which are constant. Changing these values will result in broken data
locals {
  monitoring_projects   = keys(var.monitoring_project_ids)
  apis                  = ["recommender.googleapis.com", "serviceusage.googleapis.com", "logging.googleapis.com", "cloudresourcemanager.googleapis.com", "bigqueryreservation.googleapis.com", "bigquerydatatransfer.googleapis.com"]
  admin_apis            = ["cloudresourcemanager.googleapis.com"]
  project_ids_map       = { for project in toset(local.monitoring_projects) : project => project }
  admin_project_ids_map = { for admin_project in toset(var.admin_project_ids) : admin_project => admin_project }

  admin_only_project_ids_map          = { for admin_project in setsubtract(var.admin_project_ids, local.monitoring_projects) : admin_project => admin_project }
  admin_and_monitoring_project_id_map = { for admin_project in setintersection(var.admin_project_ids, local.monitoring_projects) : admin_project => admin_project }

  config_apis = distinct(flatten([
    for each_project in local.monitoring_projects : [
      for apis in local.apis : {
        project_id = each_project
        api_name   = apis
      }
  ]]))

  # Permission required for the Unravel application to gather metrics and generate insights
  role_permission = concat([
    "bigquery.datasets.get",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.listAll",
    "bigquery.reservationAssignments.search",
    "bigquery.routines.get",
    "bigquery.routines.list",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.list",
    "bigquery.transfers.get",
    "pubsub.subscriptions.consume",
    "recommender.bigqueryCapacityCommitmentsInsights.get",
    "recommender.bigqueryCapacityCommitmentsInsights.list",
    "recommender.bigqueryCapacityCommitmentsRecommendations.get",
    "recommender.bigqueryCapacityCommitmentsRecommendations.list",
    "recommender.bigqueryPartitionClusterRecommendations.get",
    "recommender.bigqueryPartitionClusterRecommendations.list",
    "resourcemanager.projects.get",
    "serviceusage.services.use"
  ], var.x_svc_acc_permissions)

  # Permission required for the Unravel application to gather metrics from admin projects about reservations and commitments
  admin_project_role_permission = [
    "bigquery.capacityCommitments.list",
    "bigquery.jobs.create",
    "bigquery.reservations.list",
    "resourcemanager.projects.get"
  ]

  # Sink filter to get only the logs related to bigquery
  sink_filter = "(resource.type=\"bigquery_resource\" AND ((protoPayload.methodName=\"jobservice.insert\" AND  protoPayload.serviceData.jobInsertResponse.resource.jobName.jobId :*) OR (protoPayload.methodName=\"jobservice.jobcompleted\" AND protoPayload.serviceData.jobCompletedEvent.job.jobName.jobId :*))) OR (resource.type=\"bigquery_dts_config\" AND (labels.run_id :* AND resource.labels.config_id :*))"
  # Note: For permissions make sure to enable necessary api's as we add new permissions
}

# Generates a random integer used to name the resources to be unique
resource "random_integer" "unique_id" {
  max = 5000
  min = 1
}

# Create topics for Unravel Bigquery with Push/Pull subscription
module "unravel_topics" {

  source = "./modules/pubsub"

  project_ids           = var.monitoring_project_ids
  unravel_push_endpoint = var.unravel_push_endpoint
  unravel_pubsub_topic  = "${var.unravel_pubsub_topic}-${random_integer.unique_id.id}"
  pull_model            = var.pull_model

  depends_on = [
  data.google_project.project, module.google_enable_api]

}

# Create roles, service account and associated private keys
module "unravel_iam" {

  source = "./modules/iam"

  project_ids                         = local.project_ids_map
  role_permission                     = local.role_permission
  admin_project_ids                   = local.admin_project_ids_map
  admin_project_role_permission       = local.admin_project_role_permission
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

  source = "./modules/log_router"

  project_ids       = local.project_ids_map
  sink_filter       = local.sink_filter
  pub_sub_ids       = module.unravel_topics.pubsub_ids
  unravel_sink_name = "${var.unravel_sink_name}-${random_integer.unique_id.id}"

  depends_on = [module.google_enable_api]

}

# Attach Pub/Sub Publisher policy to Unravel topic
resource "google_pubsub_topic_iam_policy" "policy" {

  for_each = local.project_ids_map

  project     = module.unravel_topics.pubsub_ids[each.value].project
  topic       = module.unravel_topics.pubsub_ids[each.value].name
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

  for_each = local.project_ids_map

  binding {
    role = "roles/pubsub.publisher"

    members = [
      module.unravel_sink.sinks[each.value].writer_identity
    ]
  }
}

# Enable google pupsub apis if not already enabled.
resource "google_project_service" "cloud_pubsub_api_unravel" {

  count   = var.multi_key_auth_model ? 0 : 1
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
