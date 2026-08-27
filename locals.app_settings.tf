locals {
  # `app_settings` is nullable, and `merge()` quietly tolerates a null argument
  # while `keys()` does not. Normalize once here so inspecting the caller's keys
  # cannot turn `app_settings = null` into a plan-time error.
  app_settings = coalesce(var.app_settings, {})
  # Azure app setting names are case-insensitive, so compare on lowercase. A
  # caller who writes `website_node_default_version` has set the same setting as
  # one who writes `WEBSITE_NODE_DEFAULT_VERSION` and must suppress the module
  # default just the same.
  app_settings_keys = [for key in keys(local.app_settings) : lower(key)]
  application_insights_connection_string = try(coalesce(
    var.site_config.application_insights_connection_string,
    var.application_insights_connection_string,
  ), null)
  application_insights_key = try(coalesce(
    var.site_config.application_insights_key,
    var.application_insights_key,
  ), null)
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
  ) : {}
  logic_app_settings = local.is_logic_app ? merge(
    {
      FUNCTIONS_EXTENSION_VERSION = var.logic_app_runtime_version
      FUNCTIONS_WORKER_RUNTIME    = "node"
      AzureWebJobsStorage         = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key}"
    },
    var.logic_app_node_version != null && !contains(local.app_settings_keys, "website_node_default_version") ? {
      WEBSITE_NODE_DEFAULT_VERSION = var.logic_app_node_version
    } : {},
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
    local.app_settings,
    local.is_function_app ? local.function_app_settings : {},
    local.is_logic_app ? local.logic_app_settings : {},
    local.application_insights_connection_string != null ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = local.application_insights_connection_string
    } : {},
    local.application_insights_key != null ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = local.application_insights_key
    } : {},
  )
}
