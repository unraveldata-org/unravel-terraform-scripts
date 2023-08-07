# Create Pubsub Topic
resource "google_pubsub_topic" "unravel_topic" {
  for_each = var.project_ids

  name    = var.unravel_pubsub_topic
  project = each.key

  message_retention_duration = "604800s"
}

# Create a push or pull subscription to the PubSub topic based on the input variable pull_model
resource "google_pubsub_subscription" "unravel_subscription" {
  for_each = var.project_ids

  project = each.key
  name    = each.value

  topic = google_pubsub_topic.unravel_topic[each.key].name

  ack_deadline_seconds = 30

  enable_message_ordering = true

  dynamic "push_config" {
    for_each = var.pull_model ? [] : [each.key]
    content {
      push_endpoint = "${var.unravel_push_endpoint}/logs/bigquery/${var.project_ids[each.key]}/${var.project_ids[each.key]}/bigquery"

      attributes = {
        x-goog-version = "v1"
      }
    }
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = var.pull_model ? "120s" : "600s"
  }

}

# Enable google pupsub apis if not already enabled.
resource "google_project_service" "cloud_pubsub_api" {
  for_each = var.project_ids

  project = each.key
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


