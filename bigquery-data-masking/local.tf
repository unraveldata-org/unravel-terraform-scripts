locals {
  template_id               = random_id.random_de_id_template_id_random.hex
  de_identify_template_json = merge(
    jsondecode(file(var.dlp_deid_template_json_file)),
    { templateId = local.template_id }
  )
}

