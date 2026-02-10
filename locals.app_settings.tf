locals {
  function_app_settings = local.is_function_app ? merge(
    {
      FUNCTIONS_EXTENSION_VERSION = var.functions_extension_version
    },
    var.storage_account_name != null ? {
      AzureWebJobsStorage = var.storage_uses_managed_identity ? "" : (
        var.storage_account_access_key != null ? "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key}" : null
      )
    } : {},
    var.storage_uses_managed_identity ? {
      AzureWebJobsStorage__accountName = var.storage_account_name
    } : {},
    var.builtin_logging_enabled ? {} : {
      AzureWebJobsFeatureFlags = "EnableWorkerIndexing"
      AzureWebJobsDashboard    = ""
    },
    var.content_share_force_disabled ? {
      WEBSITE_CONTENTSHARE = ""
    } : {},
    var.site_config.application_insights_connection_string != null ? {
      APPLICATIONINSIGHTS_CONNECTION_STRING = var.site_config.application_insights_connection_string
    } : {},
    var.site_config.application_insights_key != null ? {
      APPINSIGHTS_INSTRUMENTATIONKEY = var.site_config.application_insights_key
    } : {},
  ) : {}
  logic_app_settings = local.is_logic_app ? merge(
    {
      FUNCTIONS_EXTENSION_VERSION  = var.logic_app_runtime_version
      FUNCTIONS_WORKER_RUNTIME     = "node"
      WEBSITE_NODE_DEFAULT_VERSION = "~18"
      AzureWebJobsStorage          = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key}"
    },
    var.use_extension_bundle ? {
      AzureFunctionsJobHost__extensionBundle__id      = "Microsoft.Azure.Functions.ExtensionBundle.Workflows"
      AzureFunctionsJobHost__extensionBundle__version = var.bundle_version
    } : {},
    var.storage_account_share_name != null ? {
      WEBSITE_CONTENTSHARE                     = var.storage_account_share_name
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key}"
    } : {},
  ) : {}
  merged_app_settings = merge(
    var.app_settings,
    local.is_function_app ? local.function_app_settings : {},
    local.is_logic_app ? local.logic_app_settings : {},
  )
}
