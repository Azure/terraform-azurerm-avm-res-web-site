resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Web/certificates@2025-03-01"
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
  response_export_values = [
    "properties.thumbprint",
    "properties.expirationDate",
    "properties.subjectName",
    "properties.issuer",
    "properties.keyVaultSecretStatus",
  ]
  retry = var.retry
  tags  = var.tags

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
