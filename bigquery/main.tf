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
  project_all           = concat(var.project_ids, [var.unravel_project_id])
  project_ids_map       = { for project in toset(local.project_all) : project => project }
  admin_project_ids_map = { for admin_project in toset(var.admin_project_ids) : admin_project => admin_project }

  # Permission required for the Unravel application to gather metrics and generate insights
  role_permission = concat([
    "bigquery.datasets.get",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.listAll",
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
    "bigquery.reservations.list"
  ]

  # Sink filter to get only the logs related to bigquery
  sink_filter = "(resource.type=\"bigquery_resource\" AND (protoPayload.methodName=\"jobservice.insert\" OR protoPayload.methodName=\"jobservice.jobcompleted\")) OR resource.type=\"bigquery_dts_config\""

}

# Create topics for Unravel Bigquery with Push subscription to Unravel push endpoint
module "unravel_topics" {

  source = "./modules/pubsub"

  project_ids               = local.project_ids_map
  unravel_push_endpoint     = var.unravel_push_endpoint
  unravel_push_subscription = var.unravel_push_subscription
  unravel_pubsub_topic      = var.unravel_pubsub_topic
  pull_model                = var.pull_model

  depends_on = [
  data.google_project.project]

}

# Create roles, service account and associated private keys
module "unravel_iam" {

  source = "./modules/iam"

  project_ids                   = local.project_ids_map
  role_permission               = local.role_permission
  admin_project_ids             = local.admin_project_ids_map
  admin_project_role_permission = local.admin_project_role_permission
  unravel_role                  = var.unravel_role
  admin_unravel_role            = var.admin_unravel_role
  unravel_service_account       = var.unravel_service_account
  unravel_project_id            = var.unravel_project_id
  key_based_auth_model          = var.key_based_auth_model
  depends_on = [
  data.google_project.project]

}

# Write decoded Service account private keys to filesystem
resource "local_file" "unravel_keys" {

  count    = var.key_based_auth_model ? 1 : 0
  content  = base64decode(module.unravel_iam.keys.private_key)
  filename = "${var.unravel_keys_location}/${var.unravel_project_id}.json"

}

# Create a log router sink with Unravel Pubsub topic as destination
module "unravel_sink" {

  source = "./modules/log_router"

  project_ids       = local.project_ids_map
  sink_filter       = local.sink_filter
  pub_sub_ids       = module.unravel_topics.pubsub_ids
  unravel_sink_name = var.unravel_sink_name

  depends_on = [google_project_service.enable_cloud_logging_api]

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

# Attach Pub/Sub Publisher policy to Unravel topic
resource "google_pubsub_topic_iam_policy" "policy" {

  for_each = local.project_ids_map

  project     = module.unravel_topics.pubsub_ids[each.value].project
  topic       = module.unravel_topics.pubsub_ids[each.value].name
  policy_data = data.google_iam_policy.pubsub_access[each.value].policy_data

}

# Enable resource manager API
resource "google_project_service" "enable_cloud_resource_manager_api" {
  for_each = local.project_ids_map

  project                    = each.value
  service                    = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false

  depends_on = [
  data.google_project.project]
}

# Enable cloud logging API
resource "google_project_service" "enable_cloud_logging_api" {
  for_each = local.project_ids_map

  project                    = each.value
  service                    = "logging.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false

  depends_on = [
  data.google_project.project]
}

