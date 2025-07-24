locals {
  deid_template_id = random_id.random_de_id_template_id_random.hex
  de_identify_template_json = jsondecode(file(var.dlp_deid_template_json_file))
  dlp_de_id_template_full_path = "projects/${var.project_id}/locations/${var.region}/deidentifyTemplates/${local.deid_template_id}"
  inspect_template_id = random_id.random_inspect_template_id_random.hex
  de_inspect_template_json = jsondecode(file(var.dlp_inspect_template_json_file))
  dlp_inspect_template_full_path = "projects/${var.project_id}/locations/${var.region}/inspectTemplates/${local.inspect_template_id}"
}

