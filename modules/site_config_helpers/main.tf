locals {
  app_stack = try(var.site_config.application_stack, null)
  is_linux  = var.os_type == "Linux"
}

# IP Security Restrictions
locals {
  ip_security_restrictions = [for rule in try(var.site_config.ip_restriction, []) : {
    action               = rule.action
    ipAddress            = rule.service_tag != null ? rule.service_tag : rule.ip_address
    name                 = rule.name
    priority             = rule.priority
    tag                  = rule.service_tag != null ? "ServiceTag" : (rule.ip_address != null ? "Default" : null)
    vnetSubnetResourceId = rule.virtual_network_subnet_id
    headers = rule.headers != null ? {
      x-azure-fdid     = rule.headers.x_azure_fdid
      x-fd-healthprobe = rule.headers.x_fd_health_probe
      x-forwarded-for  = rule.headers.x_forwarded_for
      x-forwarded-host = rule.headers.x_forwarded_host
    } : null
  }]
  scm_ip_security_restrictions = [for rule in try(var.site_config.scm_ip_restriction, []) : {
    action               = rule.action
    ipAddress            = rule.service_tag != null ? rule.service_tag : rule.ip_address
    name                 = rule.name
    priority             = rule.priority
    tag                  = rule.service_tag != null ? "ServiceTag" : (rule.ip_address != null ? "Default" : null)
    vnetSubnetResourceId = rule.virtual_network_subnet_id
    headers = rule.headers != null ? {
      x-azure-fdid     = rule.headers.x_azure_fdid
      x-fd-healthprobe = rule.headers.x_fd_health_probe
      x-forwarded-for  = rule.headers.x_forwarded_for
      x-forwarded-host = rule.headers.x_forwarded_host
    } : null
  }]
}

# Auto Heal Rules
locals {
  auto_heal_rules = try(var.site_config.auto_heal_rules, null) != null ? {
    actions = var.site_config.auto_heal_rules.actions != null ? {
      actionType = var.site_config.auto_heal_rules.actions.action_type
      customAction = var.site_config.auto_heal_rules.actions.custom_action != null ? {
        exe        = var.site_config.auto_heal_rules.actions.custom_action.exe
        parameters = var.site_config.auto_heal_rules.actions.custom_action.parameters
      } : null
      minProcessExecutionTime = var.site_config.auto_heal_rules.actions.min_process_execution_time
    } : null
    triggers = var.site_config.auto_heal_rules.triggers != null ? merge(
      var.site_config.auto_heal_rules.triggers.private_bytes_in_kb != null ? {
        privateBytesInKB = var.site_config.auto_heal_rules.triggers.private_bytes_in_kb
      } : {},
      var.site_config.auto_heal_rules.triggers.requests != null ? {
        requests = {
          count        = var.site_config.auto_heal_rules.triggers.requests.count
          timeInterval = var.site_config.auto_heal_rules.triggers.requests.time_interval
        }
      } : {},
      var.site_config.auto_heal_rules.triggers.slow_requests != null ? {
        slowRequests = {
          count        = var.site_config.auto_heal_rules.triggers.slow_requests.count
          timeInterval = var.site_config.auto_heal_rules.triggers.slow_requests.time_interval
          timeTaken    = var.site_config.auto_heal_rules.triggers.slow_requests.time_taken
          path         = var.site_config.auto_heal_rules.triggers.slow_requests.path
        }
      } : {},
      length(var.site_config.auto_heal_rules.triggers.slow_requests_with_path) > 0 ? {
        slowRequestsWithPath = [
          for srv in var.site_config.auto_heal_rules.triggers.slow_requests_with_path : {
            count        = srv.count
            timeInterval = srv.time_interval
            timeTaken    = srv.time_taken
            path         = srv.path
          }
        ]
      } : {},
      length(var.site_config.auto_heal_rules.triggers.status_codes) > 0 ? {
        statusCodes = [
          for scv in var.site_config.auto_heal_rules.triggers.status_codes : {
            count        = scv.count
            timeInterval = scv.time_interval
            status       = scv.status
            path         = scv.path
            subStatus    = scv.sub_status
            win32Status  = scv.win32_status
          }
        ]
      } : {},
      length(var.site_config.auto_heal_rules.triggers.status_codes_range) > 0 ? {
        statusCodesRange = [
          for scr in var.site_config.auto_heal_rules.triggers.status_codes_range : {
            count        = scr.count
            timeInterval = scr.time_interval
            statusCodes  = scr.status_codes
            path         = scr.path
          }
        ]
      } : {},
    ) : null
  } : null
}

# Application Stack / Fx Versions
locals {
  java_container = try(coalesce(
    try(var.site_config.java_container, null),
    !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_container, null) : null,
  ), null)
  java_container_version = try(coalesce(
    try(var.site_config.java_container_version, null),
    !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_container_version, null) : null,
  ), null)
  java_version = try(coalesce(
    try(var.site_config.java_version, null),
    !local.is_linux && local.app_stack != null ? try(local.app_stack.java.java_version, null) : null,
  ), null)
  linux_fx_version = local.is_linux ? try(coalesce(
    try(var.site_config.linux_fx_version, null),
    local.app_stack != null ? try(coalesce(
      try(local.app_stack.docker != null ? "DOCKER|${trimprefix(coalesce(local.app_stack.docker.docker_registry_url, ""), "https://")}/${local.app_stack.docker.docker_image_name}:${local.app_stack.docker.docker_image_tag}" : null, null),
      try(local.app_stack.python != null ? "PYTHON|${local.app_stack.python.python_version}" : null, null),
      try(local.app_stack.node != null ? "NODE|${local.app_stack.node.node_version}" : null, null),
      try(local.app_stack.dotnet != null ? "DOTNETCORE|${local.app_stack.dotnet.dotnet_version}" : null, null),
      try(local.app_stack.java != null ? "JAVA|${local.app_stack.java.java_version}-${lower(coalesce(local.app_stack.java.java_container, "java"))}${local.app_stack.java.java_container_version != null ? "-${local.app_stack.java.java_container_version}" : ""}" : null, null),
      try(local.app_stack.powershell != null ? "POWERSHELL|${local.app_stack.powershell.powershell_version}" : null, null),
      try(local.app_stack.php != null ? "PHP|${local.app_stack.php.php_version}" : null, null),
    ), null) : null,
  ), null) : null
  net_framework_version = try(coalesce(
    !local.is_linux && local.app_stack != null ? try(local.app_stack.dotnet.dotnet_version, null) : null,
    var.is_logic_app ? try(var.site_config.dotnet_framework_version, null) : null,
  ), null)
  node_version = try(coalesce(
    try(var.site_config.node_version, null),
    !local.is_linux && local.app_stack != null ? try(local.app_stack.node.node_version, null) : null,
  ), null)
  php_version = try(coalesce(
    try(var.site_config.php_version, null),
    !local.is_linux && local.app_stack != null ? try(local.app_stack.php.php_version, null) : null,
  ), null)
  powershell_version = try(coalesce(
    try(var.site_config.powershell_version, null),
    !local.is_linux && local.app_stack != null ? try(local.app_stack.powershell.powershell_version, null) : null,
  ), null)
  python_version = try(coalesce(
    try(var.site_config.python_version, null),
    !local.is_linux && local.app_stack != null ? try(local.app_stack.python.python_version, null) : null,
  ), null)
  windows_fx_version = !local.is_linux ? try(coalesce(
    try(var.site_config.windows_fx_version, null),
    local.app_stack != null ? try(
      local.app_stack.docker != null ? "DOCKER|${trimprefix(coalesce(local.app_stack.docker.docker_registry_url, ""), "https://")}/${local.app_stack.docker.docker_image_name}:${local.app_stack.docker.docker_image_tag}" : null,
      null,
    ) : null,
  ), null) : null
}

# Identity
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
