module "site_config_helpers" {
  source = "../site_config_helpers"

  os_type            = var.os_type
  managed_identities = var.managed_identities
  site_config        = var.site_config
}

locals {
  cors = var.site_config.cors != null ? {
    allowedOrigins     = var.site_config.cors.allowed_origins
    supportCredentials = var.site_config.cors.support_credentials
  } : null
  virtual_applications = var.os_type == "Windows" ? [for va in var.site_config.virtual_application : {
    physicalPath   = va.physical_path
    preloadEnabled = va.preload_enabled
    virtualPath    = va.virtual_path
    virtualDirectories = [for vd in va.virtual_directory : {
      physicalPath = vd.physical_path
      virtualPath  = vd.virtual_path
    }]
  }] : null
}

locals {
  # Connection strings
  connection_strings_body = {
    for k, v in var.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    }
  }
  # Merge app settings: slot-level + additional from main module + application insights
  merged_app_settings = merge(
    var.app_settings,
    (var.enable_application_insights && var.is_web_app ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = coalesce(
        var.site_config.application_insights_connection_string,
        var.application_insights_connection_string,
      )
      "APPINSIGHTS_INSTRUMENTATIONKEY" = coalesce(
        var.site_config.application_insights_key,
        var.application_insights_key,
      )
    } : {}),
    var.additional_app_settings,
  )
  # Storage mounts
  storage_mounts = {
    for k, v in var.storage_shares_to_mount : v.name => {
      type        = v.type
      accountName = v.account_name
      shareName   = v.share_name
      mountPath   = v.mount_path
      accessKey   = var.storage_shares_access_keys[k]
    }
  }
}
