resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/slots@2025-03-01"
  body = {
    kind = var.kind
    properties = {
      clientAffinityEnabled     = var.client_affinity_enabled
      clientCertEnabled         = var.client_certificate_enabled
      clientCertExclusionPaths  = var.client_certificate_exclusion_paths
      clientCertMode            = var.client_certificate_mode
      enabled                   = var.enabled
      httpsOnly                 = var.https_only
      keyVaultReferenceIdentity = var.key_vault_reference_identity_id
      publicNetworkAccess       = var.public_network_access_enabled ? "Enabled" : "Disabled"
      serverFarmId              = coalesce(var.service_plan_id, var.service_plan_resource_id)
      virtualNetworkSubnetId    = var.virtual_network_subnet_id
      siteConfig = var.site_config != null ? {
        alwaysOn                               = var.site_config.always_on
        apiDefinition                          = var.site_config.api_definition_url != null ? { url = var.site_config.api_definition_url } : null
        apiManagementConfig                    = var.site_config.api_management_api_id != null ? { id = var.site_config.api_management_api_id } : null
        appCommandLine                         = var.site_config.app_command_line
        defaultDocuments                       = var.site_config.default_documents
        ftpsState                              = var.site_config.ftps_state
        healthCheckPath                        = var.site_config.health_check_path
        http20Enabled                          = var.site_config.http2_enabled
        ipSecurityRestrictionsDefaultAction    = var.site_config.ip_restriction_default_action
        loadBalancing                          = var.site_config.load_balancing_mode
        managedPipelineMode                    = var.site_config.managed_pipeline_mode
        minTlsVersion                          = var.site_config.minimum_tls_version
        numberOfWorkers                        = var.site_config.worker_count
        preWarmedInstanceCount                 = var.site_config.pre_warmed_instance_count
        remoteDebuggingEnabled                 = var.site_config.remote_debugging_enabled
        remoteDebuggingVersion                 = var.site_config.remote_debugging_version
        scmIpSecurityRestrictionsDefaultAction = var.site_config.scm_ip_restriction_default_action
        scmIpSecurityRestrictionsUseMain       = var.site_config.scm_use_main_ip_restriction
        scmMinTlsVersion                       = var.site_config.scm_minimum_tls_version
        use32BitWorkerProcess                  = var.site_config.use_32_bit_worker
        vnetRouteAllEnabled                    = var.site_config.vnet_route_all_enabled
        webSocketsEnabled                      = var.site_config.websockets_enabled
        minimumElasticInstanceCount            = var.site_config.elastic_instance_minimum
        functionsRuntimeScaleMonitoringEnabled = var.is_function_app ? var.site_config.runtime_scale_monitoring_enabled : null
        autoSwapSlotName                       = var.site_config.auto_swap_slot_name
        acrUserManagedIdentityID               = var.site_config.container_registry_managed_identity_client_id
        acrUseManagedIdentityCreds             = var.site_config.container_registry_use_managed_identity
        functionAppScaleLimit                  = var.is_function_app ? var.site_config.app_scale_limit : null
        linuxFxVersion                         = local.linux_fx_version
        netFrameworkVersion                    = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.dotnet.dotnet_version, null) : null
        phpVersion                             = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.php.php_version, null) : null
        pythonVersion                          = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.python.python_version, null) : null
        nodeVersion                            = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.node.node_version, null) : null
        javaVersion                            = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.java.java_version, null) : null
        javaContainer                          = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.java.java_container, null) : null
        javaContainerVersion                   = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.java.java_container_version, null) : null
        powerShellVersion                      = !local.is_linux && var.site_config.application_stack != null ? try(var.site_config.application_stack.powershell.powershell_version, null) : null
      } : null
    }
  }
  response_export_values = [
    "identity.principalId",
  ]
  tags = var.tags

  dynamic "identity" {
    for_each = local.has_identity ? [local.identity_block] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# Slot app settings
resource "azapi_resource" "appsettings" {
  count = length(var.app_settings) > 0 || length(var.additional_app_settings) > 0 || (var.enable_application_insights && var.is_web_app) ? 1 : 0

  name      = "appsettings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/slots/config@2025-03-01"
  body = {
    properties = local.merged_app_settings
  }
  response_export_values = []
}

# Slot connection strings
resource "azapi_resource" "connectionstrings" {
  count = length(var.connection_strings) > 0 ? 1 : 0

  name      = "connectionstrings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/slots/config@2025-03-01"
  body = {
    properties = local.connection_strings_body
  }
  response_export_values = []
}

# Slot storage account mounts
resource "azapi_resource" "azurestorageaccounts" {
  count = length(var.storage_shares_to_mount) > 0 ? 1 : 0

  name      = "azurestorageaccounts"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/slots/config@2025-03-01"
  body = {
    properties = local.storage_mounts
  }
  response_export_values = []
}

# Slot FTP publishing credential policy
resource "azapi_resource" "ftp_publishing_credential_policy" {
  count = !var.ftp_publish_basic_authentication_enabled ? 1 : 0

  name      = "ftp"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2025-03-01"
  body = {
    properties = {
      allow = false
    }
  }
  response_export_values = []
}

# Slot SCM publishing credential policy
resource "azapi_resource" "scm_publishing_credential_policy" {
  count = !var.webdeploy_publish_basic_authentication_enabled ? 1 : 0

  name      = "scm"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2025-03-01"
  body = {
    properties = {
      allow = false
    }
  }
  response_export_values = []
}
