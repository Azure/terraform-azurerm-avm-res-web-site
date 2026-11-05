resource "azapi_resource_action" "detach" {
  count = var.detach_external ? 1 : 0

  type                   = var.resource_types.web_sites
  resource_id            = var.site_id
  action                 = "networkConfig/virtualNetwork"
  method                 = "DELETE"
  when                   = "apply"
  response_export_values = []
  retry                  = var.retry

  # With when=apply, destroying this action's state does not detach the site
  # again. The deployment fixture remains the sole owner of the actual site.
  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "time_sleep" "settle" {
  create_duration = "30s"
  triggers = {
    phase = var.phase
  }

  depends_on = [azapi_resource_action.detach]
}

data "azapi_resource" "site" {
  type        = var.resource_types.web_sites
  resource_id = var.site_id
  # Export the parent object so absent and null subnet properties stay distinct.
  response_export_values = ["properties"]
  retry                  = var.retry

  depends_on = [time_sleep.settle]
}

resource "terraform_data" "observation" {
  triggers_replace = var.phase
  input            = local.observation

  provisioner "local-exec" {
    command     = "& $env:AVM_422_REPORT_SCRIPT"
    interpreter = ["pwsh", "-NoProfile", "-NonInteractive", "-Command"]
    environment = {
      AVM_422_REPORT_SCRIPT = abspath("${path.module}/../../write_observation.ps1")
      AVM_422_OBSERVATION   = jsonencode(local.observation)
    }
  }
}
