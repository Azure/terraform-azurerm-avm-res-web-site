# The main App Service resource (Microsoft.Web/sites)
# This single resource replaces azurerm_windows_web_app, azurerm_linux_web_app,
# azurerm_windows_function_app, azurerm_linux_function_app,
# azurerm_function_app_flex_consumption, and azurerm_logic_app_standard.
resource "azapi_resource" "this" {
  location       = var.location
  name           = var.name
  parent_id      = local.resource_group_id
  type           = "Microsoft.Web/sites@2024-04-01"
  body           = local.body
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "properties.defaultHostName",
    "properties.customDomainVerificationId",
    "properties.outboundIpAddresses",
    "properties.possibleOutboundIpAddresses",
    "identity.principalId",
    "identity.tenantId",
  ]
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = local.has_identity ? [local.identity_block] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
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
    ignore_changes = [
      tags,
    ]
  }
}

# App settings sub-resource (Microsoft.Web/sites/config - appsettings)
# Only create if there are app settings to set
resource "azapi_resource" "appsettings" {
  count = length(local.merged_app_settings) > 0 ? 1 : 0

  name      = "appsettings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = local.merged_app_settings
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Connection strings sub-resource (Microsoft.Web/sites/config - connectionstrings)
resource "azapi_resource" "connectionstrings" {
  count = length(var.connection_strings) > 0 ? 1 : 0

  name      = "connectionstrings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = { for k, v in var.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    } }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Storage mounts sub-resource (Microsoft.Web/sites/config - azurestorageaccounts)
resource "azapi_resource" "azurestorageaccounts" {
  count = length(var.storage_shares_to_mount) > 0 ? 1 : 0

  name      = "azurestorageaccounts"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = local.storage_mounts
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Sticky settings sub-resource (Microsoft.Web/sites/config - slotConfigNames)
resource "azapi_resource" "slotconfignames" {
  count = length(var.sticky_settings) > 0 ? 1 : 0

  name      = "slotConfigNames"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = {
      appSettingNames       = flatten([for k, v in var.sticky_settings : coalesce(v.app_setting_names, [])])
      connectionStringNames = flatten([for k, v in var.sticky_settings : coalesce(v.connection_string_names, [])])
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Auth settings V1 sub-resource (Microsoft.Web/sites/config - authsettings)
# Deprecated but kept for backward compatibility
# The ARM API uses flat property names (e.g. facebookAppId, microsoftAccountClientId)
# rather than nested objects.
resource "azapi_resource" "authsettings" {
  for_each = var.auth_settings

  name      = "authsettings"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = merge(
      {
        enabled                     = each.value.enabled
        runtimeVersion              = each.value.runtime_version
        tokenStoreEnabled           = each.value.token_store_enabled
        tokenRefreshExtensionHours  = each.value.token_refresh_extension_hours
        unauthenticatedClientAction = each.value.unauthenticated_client_action
        issuer                      = each.value.issuer
        allowedExternalRedirectUrls = each.value.allowed_external_redirect_urls
        additionalLoginParams       = each.value.additional_login_parameters != null ? each.value.additional_login_parameters : null
        defaultProvider             = each.value.default_provider
      },
      # Active Directory (Azure AD) - flat properties
      length(each.value.active_directory) > 0 ? {
        clientId                = values(each.value.active_directory)[0].client_id
        allowedAudiences        = values(each.value.active_directory)[0].allowed_audiences
        clientSecret            = values(each.value.active_directory)[0].client_secret
        clientSecretSettingName = values(each.value.active_directory)[0].client_secret_setting_name
      } : {},
      # Facebook - flat properties
      length(each.value.facebook) > 0 ? {
        facebookAppId                = values(each.value.facebook)[0].app_id
        facebookAppSecret            = values(each.value.facebook)[0].app_secret
        facebookAppSecretSettingName = values(each.value.facebook)[0].app_secret_setting_name
        facebookOAuthScopes          = values(each.value.facebook)[0].oauth_scopes
      } : {},
      # GitHub - flat properties
      length(each.value.github) > 0 ? {
        gitHubClientId                = values(each.value.github)[0].client_id
        gitHubClientSecret            = values(each.value.github)[0].client_secret
        gitHubClientSecretSettingName = values(each.value.github)[0].client_secret_setting_name
        gitHubOAuthScopes             = values(each.value.github)[0].oauth_scopes
      } : {},
      # Google - flat properties
      length(each.value.google) > 0 ? {
        googleClientId                = values(each.value.google)[0].client_id
        googleClientSecret            = values(each.value.google)[0].client_secret
        googleClientSecretSettingName = values(each.value.google)[0].client_secret_setting_name
        googleOAuthScopes             = values(each.value.google)[0].oauth_scopes
      } : {},
      # Microsoft Account - flat properties
      length(each.value.microsoft) > 0 ? {
        microsoftAccountClientId                = values(each.value.microsoft)[0].client_id
        microsoftAccountClientSecret            = values(each.value.microsoft)[0].client_secret
        microsoftAccountClientSecretSettingName = values(each.value.microsoft)[0].client_secret_setting_name
        microsoftAccountOAuthScopes             = values(each.value.microsoft)[0].oauth_scopes
      } : {},
      # Twitter - flat properties
      length(each.value.twitter) > 0 ? {
        twitterConsumerKey               = values(each.value.twitter)[0].consumer_key
        twitterConsumerSecret            = values(each.value.twitter)[0].consumer_secret
        twitterConsumerSecretSettingName = values(each.value.twitter)[0].consumer_secret_setting_name
      } : {},
    )
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Auth settings V2 sub-resource (Microsoft.Web/sites/config - authsettingsV2)
resource "azapi_resource" "authsettingsv2" {
  for_each = var.auth_settings_v2

  name      = "authsettingsV2"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = {
      platform = {
        enabled        = each.value.auth_enabled
        runtimeVersion = each.value.runtime_version
        configFilePath = each.value.config_file_path
      }
      globalValidation = {
        requireAuthentication       = each.value.require_authentication
        unauthenticatedClientAction = each.value.unauthenticated_action
        excludedPaths               = each.value.excluded_paths
      }
      httpSettings = {
        requireHttps = each.value.require_https
        routes = {
          apiPrefix = each.value.http_route_api_prefix
        }
        forwardProxy = each.value.forward_proxy_convention != "NoProxy" ? {
          convention            = each.value.forward_proxy_convention
          customHostHeaderName  = each.value.forward_proxy_custom_host_header_name
          customProtoHeaderName = each.value.forward_proxy_custom_scheme_header_name
        } : null
      }
      identityProviders = {
        azureActiveDirectory = length(each.value.active_directory_v2) > 0 ? {
          for k, v in each.value.active_directory_v2 : k => {
            enabled = true
            registration = {
              clientId                          = v.client_id
              clientSecretCertificateThumbprint = v.client_secret_certificate_thumbprint
              clientSecretSettingName           = v.client_secret_setting_name
              openIdIssuer                      = v.tenant_auth_endpoint
            }
            validation = {
              allowedAudiences = v.allowed_audiences
              jwtClaimChecks = {
                allowedClientApplications = v.jwt_allowed_client_applications
                allowedGroups             = v.jwt_allowed_groups
              }
            }
          }
        } : null
      }
      login = length(each.value.login) > 0 ? {
        for k, v in each.value.login : k => {
          tokenStore = {
            enabled                    = v.token_store_enabled
            tokenRefreshExtensionHours = v.token_refresh_extension_time
            fileSystem = v.token_store_path != null ? {
              directory = v.token_store_path
            } : null
            azureBlobStorage = v.token_store_sas_setting_name != null ? {
              sasUrlSettingName = v.token_store_sas_setting_name
            } : null
          }
          preserveUrlFragmentsForLogins = v.preserve_url_fragments_for_logins
          allowedExternalRedirectUrls   = v.allowed_external_redirect_urls
          cookieExpiration = {
            convention       = v.cookie_expiration_convention
            timeToExpiration = v.cookie_expiration_time
          }
          nonce = {
            validateNonce           = v.validate_nonce
            nonceExpirationInterval = v.nonce_expiration_time
          }
        }
      } : null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Backup sub-resource (Microsoft.Web/sites/config - backup)
resource "azapi_resource" "backup" {
  for_each = var.backup

  name      = "backup"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = {
      backupName        = coalesce(each.value.name, "backup-${var.name}")
      enabled           = each.value.enabled
      storageAccountUrl = each.value.storage_account_url
      backupSchedule = each.value.schedule != null ? {
        for sk, sv in each.value.schedule : sk => {
          frequencyInterval     = sv.frequency_interval
          frequencyUnit         = sv.frequency_unit
          keepAtLeastOneBackup  = sv.keep_at_least_one_backup
          retentionPeriodInDays = sv.retention_period_days
          startTime             = sv.start_time
        }
      }[keys(each.value.schedule)[0]] : null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Logs sub-resource (Microsoft.Web/sites/config - logs)
resource "azapi_resource" "logs" {
  for_each = var.logs

  name      = "logs"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/config@2024-04-01"
  body = {
    properties = {
      detailedErrorMessages = {
        enabled = each.value.detailed_error_messages
      }
      failedRequestsTracing = {
        enabled = each.value.failed_request_tracing
      }
      applicationLogs = length(each.value.application_logs) > 0 ? {
        for alk, alv in each.value.application_logs : alk => {
          fileSystem = {
            level = alv.file_system_level
          }
          azureBlobStorage = alv.azure_blob_storage != null ? {
            level           = alv.azure_blob_storage.level
            retentionInDays = alv.azure_blob_storage.retention_in_days
            sasUrl          = alv.azure_blob_storage.sas_url
          } : null
        }
      }[keys(each.value.application_logs)[0]] : null
      httpLogs = length(each.value.http_logs) > 0 ? {
        for hlk, hlv in each.value.http_logs : hlk => {
          azureBlobStorage = hlv.azure_blob_storage_http != null ? {
            retentionInDays = hlv.azure_blob_storage_http.retention_in_days
            sasUrl          = hlv.azure_blob_storage_http.sas_url
          } : null
          fileSystem = hlv.file_system != null ? {
            retentionInDays = hlv.file_system.retention_in_days
            retentionInMb   = hlv.file_system.retention_in_mb
          } : null
        }
      }[keys(each.value.http_logs)[0]] : null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Deployment slots
resource "azapi_resource" "slot" {
  for_each = var.deployment_slots

  location  = var.location
  name      = coalesce(each.value.name, each.key)
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/slots@2024-04-01"
  body = {
    kind = local.arm_kind
    properties = {
      enabled                = each.value.enabled
      httpsOnly              = each.value.https_only
      publicNetworkAccess    = each.value.public_network_access_enabled ? "Enabled" : "Disabled"
      serverFarmId           = coalesce(each.value.service_plan_id, var.service_plan_resource_id)
      virtualNetworkSubnetId = each.value.virtual_network_subnet_id
      siteConfig = each.value.site_config != null ? {
        alwaysOn                               = each.value.site_config.always_on
        apiDefinitionUrl                       = each.value.site_config.api_definition_url
        apiManagementConfig                    = each.value.site_config.api_management_api_id != null ? { id = each.value.site_config.api_management_api_id } : null
        appCommandLine                         = each.value.site_config.app_command_line
        ftpsState                              = each.value.site_config.ftps_state
        healthCheckPath                        = each.value.site_config.health_check_path
        healthCheckEvictionTimeInMin           = each.value.site_config.health_check_eviction_time_in_min
        http20Enabled                          = each.value.site_config.http2_enabled
        ipSecurityRestrictionsDefaultAction    = each.value.site_config.ip_restriction_default_action
        loadBalancing                          = each.value.site_config.load_balancing_mode
        managedPipelineMode                    = each.value.site_config.managed_pipeline_mode
        minTlsVersion                          = each.value.site_config.minimum_tls_version
        numberOfWorkers                        = each.value.site_config.worker_count
        preWarmedInstanceCount                 = each.value.site_config.pre_warmed_instance_count
        remoteDebuggingEnabled                 = each.value.site_config.remote_debugging_enabled
        remoteDebuggingVersion                 = each.value.site_config.remote_debugging_version
        scmIpSecurityRestrictionsDefaultAction = each.value.site_config.scm_ip_restriction_default_action
        scmIpSecurityRestrictionsUseMain       = each.value.site_config.scm_use_main_ip_restriction
        scmMinTlsVersion                       = each.value.site_config.scm_minimum_tls_version
        use32BitWorkerProcess                  = each.value.site_config.use_32_bit_worker
        vnetRouteAllEnabled                    = each.value.site_config.vnet_route_all_enabled
        webSocketsEnabled                      = each.value.site_config.websockets_enabled
        minimumElasticInstanceCount            = each.value.site_config.elastic_instance_minimum
        functionsRuntimeScaleMonitoringEnabled = local.is_function_app ? each.value.site_config.runtime_scale_monitoring_enabled : null
        autoSwapSlotName                       = each.value.site_config.auto_swap_slot_name
        acrUserManagedIdentityID               = each.value.site_config.container_registry_managed_identity_client_id
        acrUseManagedIdentityCreds             = each.value.site_config.container_registry_use_managed_identity
        functionAppScaleLimit                  = local.is_function_app ? each.value.site_config.app_scale_limit : null
        # Application stack properties for slots
        linuxFxVersion       = local.slot_linux_fx_version[each.key]
        netFrameworkVersion  = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.dotnet.dotnet_version, null) : null
        phpVersion           = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.php.php_version, null) : null
        pythonVersion        = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.python.python_version, null) : null
        nodeVersion          = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.node.node_version, null) : null
        javaVersion          = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.java.java_version, null) : null
        javaContainer        = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.java.java_container, null) : null
        javaContainerVersion = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.java.java_container_version, null) : null
        powerShellVersion    = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.powershell.powershell_version, null) : null
      } : null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "properties.defaultHostName",
    "identity.principalId",
    "identity.tenantId",
  ]
  tags           = var.all_child_resources_inherit_tags ? merge(var.tags, each.value.tags) : each.value.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "identity" {
    for_each = local.has_identity ? [local.identity_block] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

# Slot app settings
resource "azapi_resource" "slot_appsettings" {
  for_each = { for k, v in var.deployment_slots : k => v if length(local.slot_app_settings[k]) > 0 }

  name      = "appsettings"
  parent_id = azapi_resource.slot[each.key].id
  type      = "Microsoft.Web/sites/slots/config@2024-04-01"
  body = {
    properties = local.slot_app_settings[each.key]
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Active slot swap
resource "azapi_resource_action" "active_slot" {
  count = var.app_service_active_slot != null ? 1 : 0

  action      = "slotsswap"
  method      = "POST"
  resource_id = azapi_resource.this.id
  type        = "Microsoft.Web/sites@2024-04-01"
  body = {
    targetSlot   = coalesce(var.deployment_slots[var.app_service_active_slot.slot_key].name, var.app_service_active_slot.slot_key)
    preserveVnet = !var.app_service_active_slot.overwrite_network_config
  }

  depends_on = [azapi_resource.slot]
}

# Custom domains - host name bindings
resource "azapi_resource" "hostname_binding" {
  for_each = { for k, v in var.custom_domains : k => v if !v.slot_as_target }

  name      = each.value.hostname
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/hostNameBindings@2024-04-01"
  body = {
    properties = {
      sslState   = each.value.ssl_state
      thumbprint = each.value.thumbprint_value
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Slot hostname bindings
resource "azapi_resource" "slot_hostname_binding" {
  for_each = { for k, v in var.custom_domains : k => v if v.slot_as_target }

  name      = each.value.hostname
  parent_id = azapi_resource.slot[each.value.app_service_slot_key].id
  type      = "Microsoft.Web/sites/slots/hostNameBindings@2024-04-01"
  body = {
    properties = {
      sslState   = each.value.ssl_state
      thumbprint = each.value.thumbprint_value
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Basic auth publishing credential policies - FTP
resource "azapi_resource" "ftp_publishing_credential_policy" {
  count = !var.ftp_publish_basic_authentication_enabled ? 1 : 0

  name      = "ftp"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01"
  body = {
    properties = {
      allow = false
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Basic auth publishing credential policies - SCM
resource "azapi_resource" "scm_publishing_credential_policy" {
  count = !var.scm_publish_basic_authentication_enabled ? 1 : 0

  name      = "scm"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01"
  body = {
    properties = {
      allow = false
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Zip deploy (if zip_deploy_file is provided)
resource "azapi_resource_action" "zip_deploy" {
  count = var.zip_deploy_file != null ? 1 : 0

  action      = "extensions/zipdeploy"
  method      = "PUT"
  resource_id = azapi_resource.this.id
  type        = "Microsoft.Web/sites@2024-04-01"
  body = {
    packageUri = var.zip_deploy_file
  }

  depends_on = [
    azapi_resource.appsettings,
    azapi_resource.connectionstrings,
  ]
}
