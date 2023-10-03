# Creates a sink for each project with destination as Pub/Sub
resource "google_logging_project_sink" "unravel_sink" {
  for_each = var.project_ids

  project = each.value

  name = var.unravel_sink_name

  # Can export to pubsub, cloud storage, or bigquery
  destination = "pubsub.googleapis.com/${var.pub_sub_ids[each.value].id}"

  # Log all WARN or higher severity messages relating to instances
  filter = var.sink_filter

  unique_writer_identity = true

}

