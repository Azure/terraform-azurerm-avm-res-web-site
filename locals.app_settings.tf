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
  # Flex Consumption (FC1) deprecates a list of app settings, and two of them are
  # ones this module emits for Function Apps: FUNCTIONS_EXTENSION_VERSION and
  # WEBSITE_CONTENTSHARE. Both are gated on var.function_app_uses_fc1 below. See
  # "Flex Consumption plan deprecations" in the Functions app settings reference.
  #
  # These are *deprecated*, not rejected — the distinction matters, and it is the
  # opposite of the siteConfig properties #345 suppressed. Those come back as a
  # hard ARM 51021 error. These do not: the table records
  # FUNCTIONS_EXTENSION_VERSION as "App Setting is set by the backend", and FC1
  # has no content share for WEBSITE_CONTENTSHARE to name. An FC1 deployment
  # carrying either one succeeds today and always has; the values are simply
  # overwritten or ignored. Omitting them stops the module from asserting
  # configuration it does not control, rather than fixing a failing deployment.
  #
  # The rest of what this module sends is not on that list. AzureWebJobsStorage
  # and its `__accountName` sibling are the *host* storage connection, which FC1
  # still requires and which the table does not name; only the deployment-storage
  # settings were replaced. AzureWebJobsFeatureFlags, AzureWebJobsDashboard and
  # APPINSIGHTS_INSTRUMENTATIONKEY are absent from the table too. See #365.
  function_app_settings = local.is_function_app ? merge(
    # Carries the same case-insensitive override guard #344 introduced for
    # WEBSITE_NODE_DEFAULT_VERSION, for the same reason: module defaults are
    # merged *after* var.app_settings, so without it a caller who sets this key
    # directly has it silently overwritten by var.functions_extension_version.
    # The guard doubles as the escape hatch from the FC1 gate above — an FC1
    # caller who really does want to pin the value can still set it explicitly.
    !var.function_app_uses_fc1 && !contains(local.app_settings_keys, "functions_extension_version") ? {
      FUNCTIONS_EXTENSION_VERSION = var.functions_extension_version
    } : {},
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
    # No-op on FC1, where there is no content share to disable.
    var.content_share_force_disabled && !var.function_app_uses_fc1 ? {
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
