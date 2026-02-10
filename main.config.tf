resource "azapi_resource" "appsettings" {
  count = length(local.merged_app_settings) > 0 ? 1 : 0

  name      = "appsettings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = local.merged_app_settings
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "connectionstrings" {
  count = length(var.connection_strings) > 0 ? 1 : 0

  name      = "connectionstrings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = { for k, v in var.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    } }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "azurestorageaccounts" {
  count = length(var.storage_shares_to_mount) > 0 ? 1 : 0

  name      = "azurestorageaccounts"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = local.storage_mounts
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "slotconfignames" {
  count = length(var.sticky_settings) > 0 ? 1 : 0

  name      = "slotConfigNames"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = {
      appSettingNames       = flatten([for k, v in var.sticky_settings : coalesce(v.app_setting_names, [])])
      connectionStringNames = flatten([for k, v in var.sticky_settings : coalesce(v.connection_string_names, [])])
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "ftp_publishing_credential_policy" {
  count = !var.ftp_publish_basic_authentication_enabled ? 1 : 0

  name      = "ftp"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-03-01"
  body = {
    properties = {
      allow = false
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "scm_publishing_credential_policy" {
  count = !var.scm_publish_basic_authentication_enabled ? 1 : 0

  name      = "scm"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-03-01"
  body = {
    properties = {
      allow = false
    }
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
