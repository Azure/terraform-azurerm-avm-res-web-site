resource "azapi_resource" "slot" {
  for_each = var.deployment_slots

  location  = var.location
  name      = coalesce(each.value.name, each.key)
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Web/sites/slots@2025-03-01"
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
        linuxFxVersion                         = local.slot_linux_fx_version[each.key]
        netFrameworkVersion                    = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.dotnet.dotnet_version, null) : null
        phpVersion                             = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.php.php_version, null) : null
        pythonVersion                          = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.python.python_version, null) : null
        nodeVersion                            = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.node.node_version, null) : null
        javaVersion                            = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.java.java_version, null) : null
        javaContainer                          = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.java.java_container, null) : null
        javaContainerVersion                   = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.java.java_container_version, null) : null
        powerShellVersion                      = !local.is_linux && each.value.site_config.application_stack != null ? try(each.value.site_config.application_stack.powershell.powershell_version, null) : null
      } : null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "identity.principalId",
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

resource "azapi_resource" "slot_appsettings" {
  for_each = { for k, v in var.deployment_slots : k => v if length(local.slot_app_settings[k]) > 0 }

  name      = "appsettings"
  parent_id = azapi_resource.slot[each.key].id
  type      = "Microsoft.Web/sites/slots/config@2025-03-01"
  body = {
    properties = local.slot_app_settings[each.key]
  }
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource_action" "active_slot" {
  count = var.app_service_active_slot != null ? 1 : 0

  action      = "slotsswap"
  method      = "POST"
  resource_id = azapi_resource.this.id
  type        = "Microsoft.Web/sites@2025-03-01"
  body = {
    targetSlot   = coalesce(var.deployment_slots[var.app_service_active_slot.slot_key].name, var.app_service_active_slot.slot_key)
    preserveVnet = !var.app_service_active_slot.overwrite_network_config
  }

  depends_on = [azapi_resource.slot]
}
