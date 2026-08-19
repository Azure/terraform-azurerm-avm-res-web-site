resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.web_certificates
  body = {
    properties = {
      serverFarmId       = var.server_farm_id
      keyVaultId         = var.key_vault_id
      keyVaultSecretName = var.key_vault_secret_name
      pfxBlob            = var.pfx_blob
      password           = var.password
      hostNames          = var.host_names
    }
  }
  ignore_body_changes = length(var.ignore_body_changes.web_certificates) > 0 ? var.ignore_body_changes.web_certificates : null
  response_export_values = [
    "properties.thumbprint",
    "properties.expirationDate",
    "properties.subjectName",
    "properties.issuer",
    "properties.keyVaultSecretStatus",
  ]
  retry = var.retry
  tags  = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  lifecycle {
    precondition {
      condition     = var.key_vault_id != null || var.pfx_blob != null
      error_message = "Either `key_vault_id` (with `key_vault_secret_name`) or `pfx_blob` must be supplied."
    }
    precondition {
      condition     = !((var.key_vault_id != null || var.key_vault_secret_name != null) && var.pfx_blob != null)
      error_message = "Set either `key_vault_id`/`key_vault_secret_name` or `pfx_blob`, not both."
    }
    precondition {
      condition     = (var.key_vault_id == null) == (var.key_vault_secret_name == null)
      error_message = "`key_vault_id` and `key_vault_secret_name` must be supplied together."
    }
  }
}
