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
    # An identity-based host storage connection *replaces* the connection string
    # rather than sitting beside it: `AzureWebJobsStorage__accountName` "sets the
    # account name of the storage account instead of using the connection string
    # in `AzureWebJobsStorage`". Emitting an empty `AzureWebJobsStorage` alongside
    # it is not a documented configuration, so omit the setting entirely.
    #
    # Omitting it here does not *remove* it from an app that already has it.
    # `modules/config_appsettings` writes through `azapi_update_resource`, which
    # GETs the resource, merges this body over it and PUTs the result, so a key
    # absent from the body keeps whatever Azure already had. That is #382, and it
    # bites harder here than anywhere else: the documentation presents the root
    # setting and the `__accountName`/`__credential` pair as alternatives, not as
    # a configuration that can coexist, so an app carrying a stale
    # `AzureWebJobsStorage` — including the empty string this module used to
    # write — stays on the connection-string path and never reaches the identity
    # settings below. The key has to be deleted out of band before an existing
    # app picks up identity-based auth, and this module has no reliable way to
    # delete it.
    #
    # Only the provider half of that is verified: AzAPI 2.12 transmits a null as
    # a JSON null rather than dropping the key, which I confirmed in the provider
    # source. The Azure half is not verified by anyone — whether a transmitted
    # JSON null clears the setting or is normalized away and leaves the old value
    # standing. The `Microsoft.Web/sites/config` reference does not say, and no
    # one has run a live deployment to find out. #382 tracks the resource-type
    # change that would fix this properly and make the question moot.
    var.storage_account_name != null && !var.storage_uses_managed_identity ? {
      AzureWebJobsStorage = var.storage_account_access_key != null ? "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_access_key}" : null
    } : {},
    # The host reads an identity-based connection as a set of properties, because
    # `__` is interpreted as a `:` path separator at runtime. `accountName` alone
    # tells the host *which* account but not *how* to authenticate, so the host
    # falls back to looking for a connection string and fails at startup. The
    # documented trio is accountName + credential + (for a user-assigned identity)
    # clientId. See the `AzureWebJobsStorage__*` entries in the Functions app
    # settings reference, and issue #367.
    #
    # Each key carries the same case-insensitive override guard #344 introduced
    # for WEBSITE_NODE_DEFAULT_VERSION: module defaults are merged *after*
    # `var.app_settings`, so without the guard a caller could not correct these
    # values. Callers on sovereign clouds or custom storage DNS must set the
    # `__blobServiceUri`/`__queueServiceUri`/`__tableServiceUri` trio themselves;
    # those are out of scope here because the module has no endpoint input.
    var.storage_uses_managed_identity && !contains(local.app_settings_keys, "azurewebjobsstorage__accountname") ? {
      AzureWebJobsStorage__accountName = var.storage_account_name
    } : {},
    var.storage_uses_managed_identity && !contains(local.app_settings_keys, "azurewebjobsstorage__credential") ? {
      AzureWebJobsStorage__credential = "managedidentity"
    } : {},
    # Omitted for a system-assigned identity, where the host uses the app's own
    # identity and the setting does not apply.
    var.storage_uses_managed_identity && var.storage_user_assigned_identity_client_id != null && !contains(local.app_settings_keys, "azurewebjobsstorage__clientid") ? {
      AzureWebJobsStorage__clientId = var.storage_user_assigned_identity_client_id
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
