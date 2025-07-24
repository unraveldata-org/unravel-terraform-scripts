resource "google_service_account" "run_service_account" {
  account_id = "${var.service_name}-runner"
  project    = var.project_id
}

resource "google_project_iam_member" "grant_role_to_sa" {
  for_each = toset([
    "roles/dlp.reader",
    "roles/dlp.user",
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.run_service_account.email}"
}

resource "google_cloud_run_v2_service" "bq_function" {
  location            = var.region
  name                = var.service_name
  project             = var.project_id
  deletion_protection = false

  template {
    service_account       = google_service_account.run_service_account.email
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    containers {
      image = var.docker_image
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
    }
  }
}

resource "google_bigquery_connection" "external_bq_fn_connection" {
  project       = var.project_id
  connection_id = "ext-${var.service_name}"
  location      = var.region
  description   = "External transformation function connection"
  cloud_resource {}
}

resource "google_project_iam_binding" "grant_bq_connection_run_invoker_role" {
  project = var.project_id
  role    = "roles/run.invoker"
  members = [
    "serviceAccount:${google_bigquery_connection.external_bq_fn_connection.cloud_resource[0].service_account_id}"
  ]
}

resource "google_bigquery_dataset" "routines_dataset" {
  project    = var.project_id
  location   = var.region
  dataset_id = var.bq_dataset
}

resource "random_id" "random_de_id_template_id_random" {
  byte_length = 8
  prefix      = "bqdlpfn_"
  keepers = {
    project_id = var.project_id
    region     = var.region
  }
}

resource "random_id" "random_inspect_template_id_random" {
  byte_length = 8
  prefix      = "bqdlpfn_inspect_"
  keepers = {
    project_id = var.project_id
    region     = var.region
  }
}

resource "null_resource" "dlp_templates" {
  triggers = {
    project_id                      = var.project_id
    region                          = var.region
    dlp_de_id_template_id           = local.deid_template_id
    dlp_de_id_template_full_path    = local.dlp_de_id_template_full_path
    dlp_inspect_template_id         = local.inspect_template_id
    dlp_inspect_template_full_path  = local.dlp_inspect_template_full_path
    deid_json_hash                  = filesha256(var.dlp_deid_template_json_file)
    inspect_json_hash               = filesha256(var.dlp_inspect_template_json_file)
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
# Create De-identify template
curl -s "https://dlp.googleapis.com/v2/projects/${self.triggers.project_id}/locations/${self.triggers.region}/deidentifyTemplates?templateId=${self.triggers.dlp_de_id_template_id}" \
  --header "X-Goog-User-Project: ${self.triggers.project_id}" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '${jsonencode(local.de_identify_template_json)}'

# Create Inspect template
curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Goog-User-Project: ${self.triggers.project_id}" \
  "https://dlp.googleapis.com/v2/projects/${self.triggers.project_id}/locations/${self.triggers.region}/inspectTemplates?templateId=${self.triggers.dlp_inspect_template_id}" \
  -d '${jsonencode(local.de_inspect_template_json)}'
EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
# Delete De-identify template
curl -s --request DELETE \
  https://dlp.googleapis.com/v2/${self.triggers.dlp_de_id_template_full_path} \
  --header "X-Goog-User-Project: ${self.triggers.project_id}" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header 'Accept: application/json' \
  --header "Content-Type: application/json"

# Delete Inspect template
curl -s --request DELETE \
  https://dlp.googleapis.com/v2/${self.triggers.dlp_inspect_template_full_path} \
  --header "X-Goog-User-Project: ${self.triggers.project_id}" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header 'Accept: application/json' \
  --header "Content-Type: application/json"
EOF
  }
}

resource "null_resource" "bq_dlp_encrypt_function" {
  depends_on = [
    null_resource.dlp_templates,
    google_cloud_run_v2_service.bq_function,
    google_bigquery_connection.external_bq_fn_connection,
    google_bigquery_dataset.routines_dataset
  ]

  triggers = {
    project_id         = var.project_id
    region             = var.region
    dataset_id         = var.bq_dataset
    cloud_service_name = google_cloud_run_v2_service.bq_function.id
    cloud_run_uri      = google_cloud_run_v2_service.bq_function.uri
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOF
bq query --project_id ${self.triggers.project_id} --use_legacy_sql=false "
CREATE OR REPLACE FUNCTION ${self.triggers.dataset_id}.dlp_freetext_encrypt(v STRING)
RETURNS STRING
REMOTE WITH CONNECTION \`${self.triggers.project_id}.${self.triggers.region}.${google_bigquery_connection.external_bq_fn_connection.connection_id}\`
OPTIONS (
  endpoint = '${self.triggers.cloud_run_uri}',
  user_defined_context = [
    ('mode', 'deidentify'),
    ('algo','dlp'),
    ('dlp-deid-template','${null_resource.dlp_templates.triggers.dlp_de_id_template_full_path}'),
    ('dlp-inspect-template','${null_resource.dlp_templates.triggers.dlp_inspect_template_full_path}')
  ]
);"
EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
bq query --project_id "${self.triggers.project_id}" \
--use_legacy_sql=false \
"DROP FUNCTION ${self.triggers.dataset_id}.dlp_freetext_encrypt"
EOF
  }
}

