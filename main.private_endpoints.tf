# TODO remove this code & var.private_endpoints if private link is not support.  Note it must be included in this module if it is supported.
resource "azurerm_private_endpoint" "this" {
  for_each = { for k, v in var.private_endpoints : k => v if var.private_endpoints_manage_dns_zone_group }

  location                      = coalesce(each.value.location, var.location)
  name                          = each.value.name != null ? each.value.name : "pep-${var.name}"
  resource_group_name           = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = var.all_child_resources_inherit_tags ? merge(var.tags, each.value.tags) : each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = (var.kind == "functionapp" || var.kind == "webapp" || var.kind == "logicapp") ? (var.kind == "functionapp" ? (var.function_app_uses_fc1 == true ? azurerm_function_app_flex_consumption.this[0].id : (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id)) : (var.kind == "webapp" ? (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id) : azurerm_logic_app_standard.this[0].id)) : null
    subresource_names              = ["sites"]
  }
  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = "sites"
      subresource_name   = "sites"
    }
  }
  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_resource_ids) > 0 ? ["this"] : []

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_resource_ids
    }
  }
}

resource "azurerm_private_endpoint" "this_unmanaged_dns_zone_groups" {
  for_each = { for k, v in var.private_endpoints : k => v if !var.private_endpoints_manage_dns_zone_group }

  location                      = coalesce(each.value.location, var.location)
  name                          = each.value.name != null ? each.value.name : "pep-${var.name}"
  resource_group_name           = each.value.resource_group_name != null ? each.value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.network_interface_name
  tags                          = var.all_child_resources_inherit_tags ? merge(var.tags, each.value.tags) : each.value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = (var.kind == "functionapp" || var.kind == "webapp" || var.kind == "logicapp") ? (var.kind == "functionapp" ? (var.function_app_uses_fc1 == true ? azurerm_function_app_flex_consumption.this[0].id : (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id)) : (var.kind == "webapp" ? (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id) : azurerm_logic_app_standard.this[0].id)) : null
    subresource_names              = ["sites"]
  }
  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = "sites"
      subresource_name   = "sites"
    }
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_private_endpoint_application_security_group_association" "this" {
  for_each = local.private_endpoint_application_security_group_associations

  application_security_group_id = each.value.asg_resource_id
  private_endpoint_id           = azurerm_private_endpoint.this[each.value.pe_key].id
}

# Deployment slot
resource "azurerm_private_endpoint" "slot" {
  for_each = { for k, v in local.slot_pe : k => v if var.private_endpoints_manage_dns_zone_group }

  location                      = coalesce(each.value.pe_value.location, var.location)
  name                          = each.value.pe_value.name != null ? each.value.pe_value.name : "pep-${var.name}"
  resource_group_name           = each.value.pe_value.resource_group_name != null ? each.value.pe_value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.pe_value.subnet_resource_id
  custom_network_interface_name = each.value.pe_value.network_interface_name
  tags                          = var.all_child_resources_inherit_tags ? merge(var.tags, each.value.pe_value.tags) : each.value.pe_value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.pe_value.private_service_connection_name != null ? each.value.pe_value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id)) : null
    subresource_names              = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? ["sites-${coalesce(azurerm_windows_function_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"] : ["sites-${coalesce(azurerm_linux_function_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"]) : (var.os_type == "Windows" ? ["sites-${coalesce(azurerm_windows_web_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"] : ["sites-${coalesce(azurerm_linux_web_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"])) : null
  }
  dynamic "ip_configuration" {
    for_each = each.value.pe_value.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? "sites-${azurerm_windows_function_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_function_app_slot.this[each.value.slot_key].name}") : (var.os_type == "Windows" ? "sites-${azurerm_windows_web_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_web_app_slot.this[each.value.slot_key].name}")) : null
      subresource_name   = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? "sites-${azurerm_windows_function_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_function_app_slot.this[each.value.slot_key].name}") : (var.os_type == "Windows" ? "sites-${azurerm_windows_web_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_web_app_slot.this[each.value.slot_key].name}")) : null
    }
  }
  dynamic "private_dns_zone_group" {
    for_each = length(each.value.pe_value.private_dns_zone_resource_ids) > 0 ? ["this"] : []

    content {
      name                 = each.value.pe_value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.pe_value.private_dns_zone_resource_ids
    }
  }
}

resource "azurerm_private_endpoint" "slot_this_unmanaged_dns_zone_groups" {
  for_each = { for k, v in local.slot_pe : k => v if !var.private_endpoints_manage_dns_zone_group }

  location                      = coalesce(each.value.pe_value.location, var.location)
  name                          = each.value.pe_value.name != null ? each.value.pe_value.name : "pep-${var.name}"
  resource_group_name           = each.value.pe_value.resource_group_name != null ? each.value.pe_value.resource_group_name : var.resource_group_name
  subnet_id                     = each.value.pe_value.subnet_resource_id
  custom_network_interface_name = each.value.pe_value.network_interface_name
  tags                          = var.all_child_resources_inherit_tags ? merge(var.tags, each.value.pe_value.tags) : each.value.pe_value.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = each.value.pe_value.private_service_connection_name != null ? each.value.pe_value.private_service_connection_name : "pse-${var.name}"
    private_connection_resource_id = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id)) : null
    subresource_names              = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? ["sites-${coalesce(azurerm_windows_function_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"] : ["sites-${coalesce(azurerm_linux_function_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"]) : (var.os_type == "Windows" ? ["sites-${coalesce(azurerm_windows_web_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"] : ["sites-${coalesce(azurerm_linux_web_app_slot.this[each.value.slot_key].name, "pep-${var.name}")}"])) : null
  }
  dynamic "ip_configuration" {
    for_each = each.value.pe_value.ip_configurations

    content {
      name               = ip_configuration.value.pe_value.name
      private_ip_address = ip_configuration.value.pe_value.private_ip_address
      member_name        = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? "sites-${azurerm_windows_function_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_function_app_slot.this[each.value.slot_key].name}") : (var.os_type == "Windows" ? "sites-${azurerm_windows_web_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_web_app_slot.this[each.value.slot_key].name}")) : null
      subresource_name   = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? "sites-${azurerm_windows_function_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_function_app_slot.this[each.value.slot_key].name}") : (var.os_type == "Windows" ? "sites-${azurerm_windows_web_app_slot.this[each.value.slot_key].name}" : "sites-${azurerm_linux_web_app_slot.this[each.value.slot_key].name}")) : null
    }
  }

  lifecycle {
    ignore_changes = [private_dns_zone_group]
  }
}

resource "azurerm_private_endpoint_application_security_group_association" "slot" {
  for_each = local.slot_private_endpoint_application_security_group_associations

  application_security_group_id = each.value.asg_resource_id
  private_endpoint_id           = azurerm_private_endpoint.this[each.value.pe_key].id
}
