resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" && var.function_app_uses_fc1 == false ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id)) : null
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  # log_analytics_destination_type = each.value.log_analytics_destination_type
  log_analytics_destination_type = null
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}