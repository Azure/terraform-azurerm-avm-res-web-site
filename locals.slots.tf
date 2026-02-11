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
  slot_connection_strings = { for slot_key, slot_value in var.deployment_slots : slot_key => {
    for k, v in slot_value.connection_strings : coalesce(v.name, k) => {
      type  = v.type
      value = v.value
    }
  } if length(slot_value.connection_strings) > 0 }
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
  slot_storage_mounts = { for slot_key, slot_value in var.deployment_slots : slot_key => {
    for k, v in slot_value.storage_shares_to_mount : v.name => {
      type        = v.type
      accountName = v.account_name
      shareName   = v.share_name
      mountPath   = v.mount_path
      accessKey   = var.slots_storage_shares_to_mount_sensitive_values[k]
    }
  } if length(slot_value.storage_shares_to_mount) > 0 }
}
