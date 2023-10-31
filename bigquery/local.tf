# Variables which are constant. Changing these values will result in broken data
locals {


  pull_model = var.polling_mode == "pull" ? true : false

  monitoring_projects = keys(var.monitoring_project_ids)

  # API's to be enabled for Monitoring projects
  apis = ["recommender.googleapis.com", "serviceusage.googleapis.com", "logging.googleapis.com", "cloudresourcemanager.googleapis.com", "bigqueryreservation.googleapis.com", "bigquerydatatransfer.googleapis.com"]

  # API's to be enabled for Admin project
  admin_apis = ["cloudresourcemanager.googleapis.com"]

  # Converting from list to Map for consistency
  project_ids_map                     = { for project in toset(local.monitoring_projects) : project => project }
  admin_project_ids_map               = { for admin_project in toset(var.admin_project_ids) : admin_project => admin_project }
  admin_only_project_ids_map          = { for admin_project in setsubtract(var.admin_project_ids, local.monitoring_projects) : admin_project => admin_project }
  admin_and_monitoring_project_id_map = { for admin_project in setintersection(var.admin_project_ids, local.monitoring_projects) : admin_project => admin_project }

  # Assigning API's for each project
  config_apis = distinct(flatten([
    for each_project in local.monitoring_projects : [
      for apis in local.apis : {
        project_id = each_project
        api_name   = apis
      }
  ]]))

  # Permission required for the Unravel application to gather metrics and generate insights for API based polling model
  api_permission = concat([
    "bigquery.datasets.get",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.listAll",
    "bigquery.reservationAssignments.search",
    "bigquery.routines.get",
    "bigquery.routines.list",
    "bigquery.tables.get",
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

  # Permission required for the Unravel application to gather metrics and generate insights for Information Schema based polling model
  info_schema_permission = concat([
    "bigquery.datasets.get",
    "bigquery.jobs.create",
    "bigquery.jobs.get",
    "bigquery.jobs.listAll",
    "bigquery.reservationAssignments.search",
    "bigquery.routines.get",
    "bigquery.routines.list",
    "bigquery.tables.get",
    "bigquery.tables.list",
    "bigquery.transfers.get",
    "recommender.bigqueryCapacityCommitmentsInsights.get",
    "recommender.bigqueryCapacityCommitmentsInsights.list",
    "recommender.bigqueryCapacityCommitmentsRecommendations.get",
    "recommender.bigqueryCapacityCommitmentsRecommendations.list",
    "recommender.bigqueryPartitionClusterRecommendations.get",
    "recommender.bigqueryPartitionClusterRecommendations.list",
    "resourcemanager.projects.get",
    "serviceusage.services.use"
  ], var.x_svc_acc_permissions)

  # Identify the permission required based on the polling mode
  role_permission = var.polling_mode == "schema" ? local.info_schema_permission : local.api_permission

  # Permission required for the Unravel application to gather metrics from admin projects about reservations and commitments
  admin_project_role_permission = [
    "bigquery.capacityCommitments.list",
    "bigquery.jobs.create",
    "bigquery.reservations.list"
  ]

  billing_project_role_permission = [
    "bigquery.jobs.create",
    "bigquery.tables.getData"
  ]
  # Sink filter to get only the logs related to bigquery
  sink_filter = "(resource.type=\"bigquery_resource\" AND ((protoPayload.methodName=\"jobservice.insert\" AND  protoPayload.serviceData.jobInsertResponse.resource.jobName.jobId :*) OR (protoPayload.methodName=\"jobservice.jobcompleted\" AND protoPayload.serviceData.jobCompletedEvent.job.jobName.jobId :*))) OR (resource.type=\"bigquery_dts_config\" AND (labels.run_id :* AND resource.labels.config_id :*))"
  # Note: For permissions make sure to enable necessary api's as we add new permissions
}


