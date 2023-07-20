# List of Log Router Sinks created and its attributes
output "sinks" {
  value = google_logging_project_sink.unravel_sink
}
