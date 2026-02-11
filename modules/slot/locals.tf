locals {
  # Connection strings
  connection_strings_body = {
    for k, v in var.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    }
  }
  has_identity = local.managed_identity_type != null
  identity_block = local.has_identity ? {
    type         = local.managed_identity_type
    identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? tolist(var.managed_identities.user_assigned_resource_ids) : null
  } : null
  is_linux = var.os_type == "Linux"
  # Compute linuxFxVersion from the application stack
  linux_fx_version = (
    local.is_linux && var.site_config.application_stack != null ? coalesce(
      try(var.site_config.application_stack.docker != null ? "DOCKER|${trimprefix(coalesce(var.site_config.application_stack.docker.docker_registry_url, ""), "https://")}/${var.site_config.application_stack.docker.docker_image_name}:${var.site_config.application_stack.docker.docker_image_tag}" : null, null),
      try(var.site_config.application_stack.python != null ? "PYTHON|${var.site_config.application_stack.python.python_version}" : null, null),
      try(var.site_config.application_stack.node != null ? "NODE|${var.site_config.application_stack.node.node_version}" : null, null),
      try(var.site_config.application_stack.dotnet != null ? "DOTNETCORE|${var.site_config.application_stack.dotnet.dotnet_version}" : null, null),
      try(var.site_config.application_stack.java != null ? "JAVA|${var.site_config.application_stack.java.java_version}-${lower(coalesce(var.site_config.application_stack.java.java_container, "java"))}${var.site_config.application_stack.java.java_container_version != null ? "-${var.site_config.application_stack.java.java_container_version}" : ""}" : null, null),
      try(var.site_config.application_stack.powershell != null ? "POWERSHELL|${var.site_config.application_stack.powershell.powershell_version}" : null, null),
      try(var.site_config.application_stack.php != null ? "PHP|${var.site_config.application_stack.php.php_version}" : null, null),
      null,
    ) : null
  )
  # Identity
  managed_identity_type = (
    var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.managed_identities.system_assigned ? "SystemAssigned" :
    length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" :
    null
  )
  # Merge app settings: slot-level + additional from main module + application insights
  merged_app_settings = merge(
    var.app_settings,
    (var.enable_application_insights && var.is_web_app ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = coalesce(
        var.site_config.application_insights_connection_string,
        var.application_insights_connection_string,
      )
      "APPINSIGHTS_INSTRUMENTATIONKEY" = coalesce(
        var.site_config.application_insights_key,
        var.application_insights_key,
      )
    } : {}),
    var.additional_app_settings,
  )
  # Storage mounts
  storage_mounts = {
    for k, v in var.storage_shares_to_mount : v.name => {
      type        = v.type
      accountName = v.account_name
      shareName   = v.share_name
      mountPath   = v.mount_path
      accessKey   = var.storage_shares_access_keys[k]
    }
  }
}
