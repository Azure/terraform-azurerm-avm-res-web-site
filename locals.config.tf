module "site_config_helpers" {
  source = "./modules/site_config_helpers"

  os_type            = var.os_type
  is_logic_app       = local.is_logic_app
  managed_identities = var.managed_identities
  site_config        = var.site_config
}

locals {
  virtual_applications = var.os_type == "Windows" && local.is_web_app ? [for va in local.virtual_applications_input : {
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
  cors = var.site_config.cors != null ? {
    allowedOrigins     = var.site_config.cors.allowed_origins
    supportCredentials = var.site_config.cors.support_credentials
  } : null
}

locals {
  site_config_body = {
    alwaysOn            = var.site_config.always_on
    apiDefinition       = var.site_config.api_definition_url != null ? { url = var.site_config.api_definition_url } : null
    apiManagementConfig = var.site_config.api_management_api_id != null ? { id = var.site_config.api_management_api_id } : null
    appCommandLine      = var.site_config.app_command_line
    autoHealEnabled     = var.site_config.auto_heal_enabled
    autoHealRules       = module.site_config_helpers.auto_heal_rules

    cors                        = local.cors
    defaultDocuments            = var.site_config.default_documents
    detailedErrorLoggingEnabled = var.site_config.detailed_error_logging_enabled
    documentRoot                = var.site_config.document_root
    elasticWebAppScaleLimit     = var.site_config.elastic_web_app_scale_limit
    experiments = var.site_config.experiments != null ? {
      rampUpRules = [for rule in coalesce(var.site_config.experiments.ramp_up_rules, []) : {
        actionHostName            = rule.action_host_name
        changeDecisionCallbackUrl = rule.change_decision_callback_url
        changeIntervalInMinutes   = rule.change_interval_in_minutes
        changeStep                = rule.change_step
        maxReroutePercentage      = rule.max_reroute_percentage
        minReroutePercentage      = rule.min_reroute_percentage
        name                      = rule.name
        reroutePercentage         = rule.reroute_percentage
      }]
    } : null
    ftpsState = var.site_config.ftps_state
    handlerMappings = var.site_config.handler_mappings != null ? [for hm in var.site_config.handler_mappings : {
      arguments       = hm.arguments
      extension       = hm.extension
      scriptProcessor = hm.script_processor
    }] : null
    healthCheckPath                     = var.site_config.health_check_path
    http20Enabled                       = var.site_config.http2_enabled
    http20ProxyFlag                     = var.site_config.http20_proxy_flag
    httpLoggingEnabled                  = var.site_config.http_logging_enabled
    ipSecurityRestrictions              = length(module.site_config_helpers.ip_security_restrictions) > 0 ? module.site_config_helpers.ip_security_restrictions : null
    ipSecurityRestrictionsDefaultAction = var.site_config.ip_restriction_default_action
    limits = var.site_config.limits != null ? {
      maxDiskSizeInMb  = var.site_config.limits.max_disk_size_in_mb
      maxMemoryInMb    = var.site_config.limits.max_memory_in_mb
      maxPercentageCpu = var.site_config.limits.max_percentage_cpu
    } : null
    loadBalancing                          = var.site_config.load_balancing_mode
    logsDirectorySizeLimit                 = var.site_config.logs_directory_size_limit
    managedPipelineMode                    = var.site_config.managed_pipeline_mode
    minTlsCipherSuite                      = var.site_config.min_tls_cipher_suite
    minTlsVersion                          = var.site_config.minimum_tls_version
    numberOfWorkers                        = var.site_config.worker_count
    preWarmedInstanceCount                 = var.site_config.pre_warmed_instance_count
    remoteDebuggingEnabled                 = var.site_config.remote_debugging_enabled
    remoteDebuggingVersion                 = var.site_config.remote_debugging_version
    requestTracingEnabled                  = var.site_config.request_tracing_enabled
    requestTracingExpirationTime           = var.site_config.request_tracing_expiration_time
    scmIpSecurityRestrictions              = length(module.site_config_helpers.scm_ip_security_restrictions) > 0 ? module.site_config_helpers.scm_ip_security_restrictions : null
    scmIpSecurityRestrictionsDefaultAction = var.site_config.scm_ip_restriction_default_action
    scmIpSecurityRestrictionsUseMain       = var.site_config.scm_use_main_ip_restriction
    scmMinTlsVersion                       = var.site_config.scm_minimum_tls_version
    tracingOptions                         = var.site_config.tracing_options
    use32BitWorkerProcess                  = var.site_config.use_32_bit_worker
    virtualApplications                    = local.virtual_applications
    vnetPrivatePortsCount                  = var.site_config.vnet_private_ports_count
    vnetRouteAllEnabled                    = var.site_config.vnet_route_all_enabled
    webSocketsEnabled                      = var.site_config.websockets_enabled
    websiteTimeZone                        = var.site_config.website_time_zone
    linuxFxVersion                         = module.site_config_helpers.linux_fx_version
    windowsFxVersion                       = module.site_config_helpers.windows_fx_version
    netFrameworkVersion                    = module.site_config_helpers.net_framework_version
    phpVersion                             = module.site_config_helpers.php_version
    pythonVersion                          = module.site_config_helpers.python_version
    nodeVersion                            = module.site_config_helpers.node_version
    javaVersion                            = module.site_config_helpers.java_version
    javaContainer                          = module.site_config_helpers.java_container
    javaContainerVersion                   = module.site_config_helpers.java_container_version
    powerShellVersion                      = module.site_config_helpers.powershell_version
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
