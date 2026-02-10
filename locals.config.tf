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

locals {
  cors = var.site_config.cors != null ? {
    allowedOrigins     = var.site_config.cors.allowed_origins
    supportCredentials = var.site_config.cors.support_credentials
  } : null
}

locals {
  app_stack = var.site_config.application_stack
  # Linux uses linuxFxVersion in "RUNTIME|VERSION" format
  linux_fx_version = local.is_linux ? coalesce(
    try(local.app_stack.docker != null ? "DOCKER|${trimprefix(coalesce(local.app_stack.docker.docker_registry_url, ""), "https://")}/${local.app_stack.docker.docker_image_name}:${local.app_stack.docker.docker_image_tag}" : null, null),
    try(local.app_stack.python != null ? "PYTHON|${local.app_stack.python.python_version}" : null, null),
    try(local.app_stack.node != null ? "NODE|${local.app_stack.node.node_version}" : null, null),
    try(local.app_stack.dotnet != null ? "DOTNETCORE|${local.app_stack.dotnet.dotnet_version}" : null, null),
    try(local.app_stack.java != null ? "JAVA|${local.app_stack.java.java_version}-${lower(coalesce(local.app_stack.java.java_container, "java"))}${local.app_stack.java.java_container_version != null ? "-${local.app_stack.java.java_container_version}" : ""}" : null, null),
    try(local.app_stack.powershell != null ? "POWERSHELL|${local.app_stack.powershell.powershell_version}" : null, null),
    try(local.app_stack.php != null ? "PHP|${local.app_stack.php.php_version}" : null, null),
    var.site_config.linux_fx_version,
  ) : null
  java_container         = !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_container, null) : null
  java_container_version = !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_container_version, null) : null
  java_version           = !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_version, null) : null
  net_framework_version = !local.is_linux && local.app_stack != null ? try(local.app_stack.dotnet.dotnet_version, null) : (
    local.is_logic_app ? var.site_config.dotnet_framework_version : null
  )
  node_version       = !local.is_linux && local.app_stack != null ? try(local.app_stack.node.node_version, null) : null
  php_version        = !local.is_linux && local.app_stack != null ? try(local.app_stack.php.php_version, null) : null
  powershell_version = !local.is_linux && local.app_stack != null ? try(local.app_stack.powershell.powershell_version, null) : null
  python_version     = !local.is_linux && local.app_stack != null ? try(local.app_stack.python.python_version, null) : null
  windows_fx_version = !local.is_linux && local.app_stack != null ? try(
    local.app_stack.docker != null ? "DOCKER|${trimprefix(coalesce(local.app_stack.docker.docker_registry_url, ""), "https://")}/${local.app_stack.docker.docker_image_name}:${local.app_stack.docker.docker_image_tag}" : null,
    null
  ) : null
}

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
    linuxFxVersion                         = local.linux_fx_version
    windowsFxVersion                       = local.windows_fx_version
    netFrameworkVersion                    = local.net_framework_version
    phpVersion                             = local.php_version
    pythonVersion                          = local.python_version
    nodeVersion                            = local.node_version
    javaVersion                            = local.java_version
    javaContainer                          = local.java_container
    javaContainerVersion                   = local.java_container_version
    powerShellVersion                      = local.powershell_version
    functionsRuntimeScaleMonitoringEnabled = local.is_function_app ? var.site_config.runtime_scale_monitoring_enabled : null
    minimumElasticInstanceCount            = var.site_config.elastic_instance_minimum
    scmType                                = local.is_logic_app ? var.site_config.scm_type : null
    acrUseManagedIdentityCreds             = var.site_config.container_registry_use_managed_identity
    acrUserManagedIdentityID               = var.site_config.container_registry_managed_identity_client_id
    functionAppScaleLimit                  = local.is_function_app ? var.site_config.app_scale_limit : null
    localMySqlEnabled                      = local.is_web_app ? var.site_config.local_mysql_enabled : null
    autoSwapSlotName                       = var.site_config.auto_swap_slot_name
  }
}

locals {
  storage_mounts = { for k, v in var.storage_shares_to_mount : v.name => {
    type        = v.type
    accountName = v.account_name
    shareName   = v.share_name
    mountPath   = v.mount_path
    accessKey   = v.access_key
  } }
}
