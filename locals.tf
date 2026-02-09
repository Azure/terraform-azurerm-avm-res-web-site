locals {
  # Compute the ARM 'kind' property from var.kind and var.os_type
  # ARM API uses: "app" (Windows webapp), "app,linux" (Linux webapp),
  # "functionapp" (Windows func), "functionapp,linux" (Linux func),
  # "functionapp,linux,container,workflowapp" (Logic App on Linux)
  arm_kind = (
    var.kind == "webapp" ? (var.os_type == "Linux" ? "app,linux" : "app") :
    var.kind == "functionapp" ? (var.os_type == "Linux" ? "functionapp,linux" : "functionapp") :
    var.kind == "logicapp" ? "functionapp,linux,container,workflowapp" :
    "app"
  )
  # Deployment slot keys
  deployment_slot_keys = length(var.deployment_slots) > 0 ? keys(var.deployment_slots) : null
  # Whether this is a Function App
  is_function_app = var.kind == "functionapp"
  # Whether the site is Linux
  is_linux = var.os_type == "Linux"
  # Whether this is a Logic App
  is_logic_app = var.kind == "logicapp"
  # Whether this is a Web App
  is_web_app = var.kind == "webapp"
  # Resource group ID constructed from subscription and resource group name
  resource_group_id = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
}

# Data source for subscription info (unconditional, needed for resource_group_id)
data "azapi_client_config" "this" {}

locals {
  subscription_id = data.azapi_client_config.this.subscription_id
  tenant_id       = data.azapi_client_config.this.tenant_id
}

# Managed identity mapping for the ARM identity block
locals {
  has_identity = local.managed_identity_type != null
  identity_block = local.has_identity ? {
    type         = local.managed_identity_type
    identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? tolist(var.managed_identities.user_assigned_resource_ids) : null
  } : null
  managed_identity_type = (
    var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.managed_identities.system_assigned ? "SystemAssigned" :
    length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" :
    null
  )
}

# IP restrictions mapping to ARM format
locals {
  ip_security_restrictions = [for rule in var.site_config.ip_restriction : {
    action               = rule.action
    ipAddress            = rule.ip_address
    name                 = rule.name
    priority             = rule.priority
    tag                  = rule.service_tag != null ? "ServiceTag" : (rule.ip_address != null ? "Default" : null)
    serviceTag           = rule.service_tag
    vnetSubnetResourceId = rule.virtual_network_subnet_id
    headers = rule.headers != null ? {
      x-azure-fdid     = rule.headers.x_azure_fdid
      x-fd-healthprobe = rule.headers.x_fd_health_probe
      x-forwarded-for  = rule.headers.x_forwarded_for
      x-forwarded-host = rule.headers.x_forwarded_host
    } : null
  }]
  scm_ip_security_restrictions = [for rule in var.site_config.scm_ip_restriction : {
    action               = rule.action
    ipAddress            = rule.ip_address
    name                 = rule.name
    priority             = rule.priority
    tag                  = rule.service_tag != null ? "ServiceTag" : (rule.ip_address != null ? "Default" : null)
    serviceTag           = rule.service_tag
    vnetSubnetResourceId = rule.virtual_network_subnet_id
    headers = rule.headers != null ? {
      x-azure-fdid     = rule.headers.x_azure_fdid
      x-fd-healthprobe = rule.headers.x_fd_health_probe
      x-forwarded-for  = rule.headers.x_forwarded_for
      x-forwarded-host = rule.headers.x_forwarded_host
    } : null
  }]
}

# Virtual applications mapping (Windows only)
locals {
  virtual_applications = var.os_type == "Windows" && local.is_web_app ? [for va in var.site_config.virtual_application : {
    physicalPath   = va.physical_path
    preloadEnabled = va.preload_enabled
    virtualPath    = va.virtual_path
    virtualDirectories = [for vd in va.virtual_directory : {
      physicalPath = vd.physical_path
      virtualPath  = vd.virtual_path
    }]
  }] : null
}

# CORS mapping
locals {
  cors = var.site_config.cors != null ? {
    allowedOrigins     = var.site_config.cors.allowed_origins
    supportCredentials = var.site_config.cors.support_credentials
  } : null
}

# Application stack mapping to ARM siteConfig properties
locals {
  app_stack = var.site_config.application_stack
  # Windows currentStack metadata (used by portal, set via WEBSITE_STACK app setting or siteConfig metadata)
  current_stack          = !local.is_linux && local.app_stack != null ? try(local.app_stack.dotnet.current_stack, null) : null
  java_container         = !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_container, null) : null
  java_container_version = !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_container_version, null) : null
  java_version           = !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_version, null) : null
  # Linux uses linuxFxVersion in "RUNTIME|VERSION" format
  linux_fx_version = local.is_linux ? coalesce(
    # Docker: "DOCKER|registry/image:tag"
    try(local.app_stack.docker != null ? "DOCKER|${trimprefix(coalesce(local.app_stack.docker.docker_registry_url, ""), "https://")}/${local.app_stack.docker.docker_image_name}:${local.app_stack.docker.docker_image_tag}" : null, null),
    # Python: "PYTHON|version"
    try(local.app_stack.python != null ? "PYTHON|${local.app_stack.python.python_version}" : null, null),
    # Node: "NODE|version"
    try(local.app_stack.node != null ? "NODE|${local.app_stack.node.node_version}" : null, null),
    # .NET: "DOTNETCORE|version"
    try(local.app_stack.dotnet != null ? "DOTNETCORE|${local.app_stack.dotnet.dotnet_version}" : null, null),
    # Java: "JAVA|version-java-container"
    try(local.app_stack.java != null ? "JAVA|${local.app_stack.java.java_version}-${lower(coalesce(local.app_stack.java.java_container, "java"))}${local.app_stack.java.java_container_version != null ? "-${local.app_stack.java.java_container_version}" : ""}" : null, null),
    # PowerShell: "POWERSHELL|version"
    try(local.app_stack.powershell != null ? "POWERSHELL|${local.app_stack.powershell.powershell_version}" : null, null),
    # PHP: "PHP|version"
    try(local.app_stack.php != null ? "PHP|${local.app_stack.php.php_version}" : null, null),
    # Fallback: use explicit linux_fx_version from site_config
    var.site_config.linux_fx_version,
  ) : null
  net_framework_version = !local.is_linux && local.app_stack != null ? try(local.app_stack.dotnet.dotnet_version, null) : (
    local.is_logic_app ? var.site_config.dotnet_framework_version : null
  )
  node_version       = !local.is_linux && local.app_stack != null ? try(local.app_stack.node.node_version, null) : null
  php_version        = !local.is_linux && local.app_stack != null ? try(local.app_stack.php.php_version, null) : null
  powershell_version = !local.is_linux && local.app_stack != null ? try(local.app_stack.powershell.powershell_version, null) : null
  python_version     = !local.is_linux && local.app_stack != null ? try(local.app_stack.python.python_version, null) : null
  # Windows uses individual version properties or windowsFxVersion for containers
  windows_fx_version = !local.is_linux && local.app_stack != null ? try(
    local.app_stack.docker != null ? "DOCKER|${trimprefix(coalesce(local.app_stack.docker.docker_registry_url, ""), "https://")}/${local.app_stack.docker.docker_image_name}:${local.app_stack.docker.docker_image_tag}" : null,
    null
  ) : null
}

# Function App specific app settings
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
  # Merge all app settings: user-provided + framework-specific
  merged_app_settings = merge(
    var.app_settings,
    local.is_function_app ? local.function_app_settings : {},
    local.is_logic_app ? local.logic_app_settings : {},
  )
}

# Auto heal rules mapping to ARM format
locals {
  auto_heal_rules = length(var.auto_heal_setting) > 0 ? {
    for k, v in var.auto_heal_setting : k => {
      actions = v.action != null ? {
        actionType = v.action.action_type
        customAction = v.action.custom_action != null ? {
          exe        = v.action.custom_action.executable
          parameters = v.action.custom_action.parameters
        } : null
        minProcessExecutionTime = v.action.minimum_process_execution_time
      } : null
      triggers = v.trigger != null ? merge(
        v.trigger.private_memory_kb != null ? {
          privateBytesInKB = v.trigger.private_memory_kb
        } : {},
        length(v.trigger.requests) > 0 ? {
          requests = {
            for rk, rv in v.trigger.requests : rk => {
              count        = rv.count
              timeInterval = rv.interval
            }
          }
        } : {},
        length(v.trigger.slow_request) > 0 ? {
          slowRequests = {
            for srk, srv in v.trigger.slow_request : srk => {
              count        = srv.count
              timeInterval = srv.interval
              timeTaken    = srv.time_taken
              path         = srv.path
            }
          }
        } : {},
        length(v.trigger.slow_request_with_path) > 0 ? {
          slowRequestsWithPath = [
            for srk, srv in v.trigger.slow_request_with_path : {
              count        = srv.count
              timeInterval = srv.interval
              timeTaken    = srv.time_taken
              path         = srv.path
            }
          ]
        } : {},
        length(v.trigger.status_code) > 0 ? {
          statusCodes = [
            for sck, scv in v.trigger.status_code : {
              count           = scv.count
              timeInterval    = scv.interval
              status          = scv.status_code_range
              path            = scv.path
              subStatus       = scv.sub_status
              win32StatusCode = scv.win32_status_code
            }
          ]
        } : {},
      ) : null
    }
  }[keys(var.auto_heal_setting)[0]] : null
}

# Site config body for ARM API siteConfig property
locals {
  site_config_body = {
    alwaysOn                               = var.site_config.always_on
    apiDefinitionUrl                       = var.site_config.api_definition_url
    apiManagementConfig                    = var.site_config.api_management_api_id != null ? { id = var.site_config.api_management_api_id } : null
    appCommandLine                         = var.site_config.app_command_line
    autoHealEnabled                        = length(var.auto_heal_setting) > 0 ? true : null
    autoHealRules                          = local.auto_heal_rules
    cors                                   = local.cors
    defaultDocuments                       = var.site_config.default_documents
    ftpsState                              = var.site_config.ftps_state
    healthCheckPath                        = var.site_config.health_check_path
    healthCheckEvictionTimeInMin           = var.site_config.health_check_eviction_time_in_min
    http20Enabled                          = var.site_config.http2_enabled
    ipSecurityRestrictions                 = length(local.ip_security_restrictions) > 0 ? local.ip_security_restrictions : null
    ipSecurityRestrictionsDefaultAction    = var.site_config.ip_restriction_default_action
    loadBalancing                          = var.site_config.load_balancing_mode
    managedPipelineMode                    = var.site_config.managed_pipeline_mode
    minTlsVersion                          = var.site_config.minimum_tls_version
    numberOfWorkers                        = var.site_config.worker_count
    preWarmedInstanceCount                 = var.site_config.pre_warmed_instance_count
    remoteDebuggingEnabled                 = var.site_config.remote_debugging_enabled
    remoteDebuggingVersion                 = var.site_config.remote_debugging_version
    scmIpSecurityRestrictions              = length(local.scm_ip_security_restrictions) > 0 ? local.scm_ip_security_restrictions : null
    scmIpSecurityRestrictionsDefaultAction = var.site_config.scm_ip_restriction_default_action
    scmIpSecurityRestrictionsUseMain       = var.site_config.scm_use_main_ip_restriction
    scmMinTlsVersion                       = var.site_config.scm_minimum_tls_version
    use32BitWorkerProcess                  = var.site_config.use_32_bit_worker
    virtualApplications                    = local.virtual_applications
    vnetRouteAllEnabled                    = var.site_config.vnet_route_all_enabled
    webSocketsEnabled                      = var.site_config.websockets_enabled
    # Application stack properties
    linuxFxVersion       = local.linux_fx_version
    windowsFxVersion     = local.windows_fx_version
    netFrameworkVersion  = local.net_framework_version
    phpVersion           = local.php_version
    pythonVersion        = local.python_version
    nodeVersion          = local.node_version
    javaVersion          = local.java_version
    javaContainer        = local.java_container
    javaContainerVersion = local.java_container_version
    powerShellVersion    = local.powershell_version
    # Function App specific
    functionsRuntimeScaleMonitoringEnabled = local.is_function_app ? var.site_config.runtime_scale_monitoring_enabled : null
    minimumElasticInstanceCount            = var.site_config.elastic_instance_minimum
    # Logic App specific
    scmType = local.is_logic_app ? var.site_config.scm_type : null
    # Container registry
    acrUseManagedIdentityCreds = var.site_config.container_registry_use_managed_identity
    acrUserManagedIdentityID   = var.site_config.container_registry_managed_identity_client_id
    # App scale limit (function app)
    functionAppScaleLimit = local.is_function_app ? var.site_config.app_scale_limit : null
    # Local MySQL (web app)
    localMySqlEnabled = local.is_web_app ? var.site_config.local_mysql_enabled : null
    # Auto swap
    autoSwapSlotName = var.site_config.auto_swap_slot_name
  }
}

# Storage mounts (azureStorageAccounts config sub-resource)
locals {
  storage_mounts = { for k, v in var.storage_shares_to_mount : v.name => {
    type        = v.type
    accountName = v.account_name
    shareName   = v.share_name
    mountPath   = v.mount_path
    accessKey   = v.access_key
  } }
}

# The main body for the Microsoft.Web/sites resource
locals {
  body = {
    kind = local.arm_kind
    properties = merge(
      {
        enabled                   = var.enabled
        httpsOnly                 = var.https_only
        serverFarmId              = var.service_plan_resource_id
        reserved                  = local.is_linux
        clientAffinityEnabled     = var.client_affinity_enabled
        clientCertEnabled         = var.client_certificate_enabled
        clientCertMode            = var.client_certificate_enabled ? var.client_certificate_mode : null
        clientCertExclusionPaths  = var.client_certificate_exclusion_paths
        publicNetworkAccess       = var.public_network_access_enabled ? "Enabled" : "Disabled"
        virtualNetworkSubnetId    = var.virtual_network_subnet_id
        keyVaultReferenceIdentity = var.key_vault_reference_identity_id
        siteConfig                = local.site_config_body
        vnetBackupRestoreEnabled  = var.virtual_network_backup_restore_enabled
        vnetContentShareEnabled   = var.vnet_content_share_enabled
        vnetImagePullEnabled      = var.vnet_image_pull_enabled
      },
      # Function App specific: Flex Consumption properties
      var.function_app_uses_fc1 ? {
        functionAppConfig = {
          deployment = {
            storage = {
              type  = var.storage_container_type
              value = var.storage_container_endpoint
              authentication = {
                type                               = var.storage_authentication_type
                storageAccountConnectionStringName = null
                userAssignedIdentityResourceId     = var.storage_user_assigned_identity_id
              }
            }
          }
          scaleAndConcurrency = {
            alwaysReady          = length(var.always_ready) > 0 ? [for k, v in var.always_ready : { name = coalesce(v.name, k), instanceCount = v.instance_count }] : null
            maximumInstanceCount = var.maximum_instance_count
            instanceMemoryMB     = var.instance_memory_in_mb
          }
          runtime = {
            name    = var.fc1_runtime_name
            version = var.fc1_runtime_version
          }
        }
      } : {},
      # Function App (non-FC1): dailyMemoryTimeQuota
      local.is_function_app && !var.function_app_uses_fc1 ? {
        dailyMemoryTimeQuota = var.daily_memory_time_quota
      } : {},
    )
  }
}

# Private endpoint locals
locals {
  pe_role_assignments = { for ra in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for rk, rv in pe_v.role_assignments : {
        private_endpoint_key = pe_k
        ra_key               = rk
        role_assignment      = rv
      }
    ]
  ]) : "${ra.private_endpoint_key}-${ra.ra_key}" => ra }
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}

# Deployment slot locals
locals {
  slot_pe = { for pe in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for pe_k, pe_v in slot_v.private_endpoints : {
        slot_key = slot_k
        pe_key   = pe_k
        pe_value = pe_v
      }
    ]
  ]) : "${pe.slot_key}-${pe.pe_key}" => pe }
  slot_pe_role_assignments = { for ra in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for pe_k, pe_v in slot_v.private_endpoints : [
        for rk, rv in pe_v.role_assignments : {
          private_endpoint_key = pe_k
          ra_key               = rk
          role_assignment      = rv
        }
      ]
    ]
  ]) : "${ra.private_endpoint_key}-${ra.ra_key}" => ra }
  slot_private_endpoint_application_security_group_associations = { for assoc in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for pe_k, pe_v in slot_v.private_endpoints : [
        for asg_k, asg_v in pe_v.application_security_group_associations : {
          asg_key         = asg_k
          pe_key          = pe_k
          asg_resource_id = asg_v
        }
      ]
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  slot_ra = { for ra in flatten([
    for slot_k, slot_v in var.deployment_slots : [
      for rk, rv in slot_v.role_assignments : {
        slot_key        = slot_k
        ra_key          = rk
        role_assignment = rv
      }
    ]
  ]) : "${ra.slot_key}-${ra.ra_key}" => ra }
}

# Application Insights app settings merge
locals {
  slot_app_settings = { for slot_key, slot_value in var.deployment_slots : slot_key => merge(
    slot_value.app_settings,
    (var.enable_application_insights && local.is_web_app ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = coalesce(
        slot_value.site_config.application_insights_connection_string,
        try(azapi_resource.application_insights[0].output.properties.ConnectionString, null),
      )
      "APPINSIGHTS_INSTRUMENTATIONKEY" = coalesce(
        slot_value.site_config.application_insights_key,
        try(azapi_resource.application_insights[0].output.properties.InstrumentationKey, null),
      )
    } : {}),
    lookup(var.slot_app_settings, slot_key, {}),
  ) }
  # Slot application stack to ARM siteConfig property mappings
  slot_linux_fx_version = { for slot_key, slot_value in var.deployment_slots : slot_key => (
    local.is_linux && slot_value.site_config.application_stack != null ? coalesce(
      try(slot_value.site_config.application_stack.docker != null ? "DOCKER|${trimprefix(coalesce(slot_value.site_config.application_stack.docker.docker_registry_url, ""), "https://")}/${slot_value.site_config.application_stack.docker.docker_image_name}:${slot_value.site_config.application_stack.docker.docker_image_tag}" : null, null),
      try(slot_value.site_config.application_stack.python != null ? "PYTHON|${slot_value.site_config.application_stack.python.python_version}" : null, null),
      try(slot_value.site_config.application_stack.node != null ? "NODE|${slot_value.site_config.application_stack.node.node_version}" : null, null),
      try(slot_value.site_config.application_stack.dotnet != null ? "DOTNETCORE|${slot_value.site_config.application_stack.dotnet.dotnet_version}" : null, null),
      try(slot_value.site_config.application_stack.java != null ? "JAVA|${slot_value.site_config.application_stack.java.java_version}-${lower(coalesce(slot_value.site_config.application_stack.java.java_container, "java"))}${slot_value.site_config.application_stack.java.java_container_version != null ? "-${slot_value.site_config.application_stack.java.java_container_version}" : ""}" : null, null),
      try(slot_value.site_config.application_stack.powershell != null ? "POWERSHELL|${slot_value.site_config.application_stack.powershell.powershell_version}" : null, null),
      try(slot_value.site_config.application_stack.php != null ? "PHP|${slot_value.site_config.application_stack.php.php_version}" : null, null),
      null,
    ) : null
  ) }
}

# Logs helper locals
locals {
  webapp_alk                  = local.webapp_logs_key != null ? local.webapp_application_logs_key[0] : null
  webapp_application_logs_key = local.webapp_logs_key != null ? keys(var.logs[local.webapp_lk].application_logs) : null
  webapp_keys = {
    logs_key             = local.webapp_logs_key
    application_logs_key = local.webapp_application_logs_key
    lk                   = local.webapp_lk
    alk                  = local.webapp_alk
  }
  webapp_lk       = local.webapp_logs_key != null ? local.webapp_logs_key[0] : null
  webapp_logs_key = length(var.logs) == 1 ? keys(var.logs) : null
}
