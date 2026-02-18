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
  virtual_applications = var.os_type == "Windows" ? [for va in local.virtual_applications_input : {
    physicalPath   = va.physical_path
    preloadEnabled = va.preload_enabled
    virtualPath    = va.virtual_path
    virtualDirectories = [for vd in va.virtual_directory : {
      physicalPath = vd.physical_path
      virtualPath  = vd.virtual_path
    }]
  }] : null
  virtual_applications_input = length(var.site_config.virtual_application) > 0 ? var.site_config.virtual_application : [{
    physical_path     = "site\\wwwroot"
    preload_enabled   = false
    virtual_path      = "/"
    virtual_directory = []
  }]
}

locals {
  # Merge app settings: slot-level + additional from main module + application insights
  application_insights_connection_string = try(coalesce(
    var.site_config.application_insights_connection_string,
    var.application_insights_connection_string,
  ), null)
  application_insights_key = try(coalesce(
    var.site_config.application_insights_key,
    var.application_insights_key,
  ), null)
  merged_app_settings = merge(
    var.app_settings,
    local.application_insights_connection_string != null ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = local.application_insights_connection_string
    } : {},
    local.application_insights_key != null ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = local.application_insights_key
    } : {},
    var.sensitive_app_settings,
  )
}
