module "config_logs" {
  source   = "./modules/config_logs"
  for_each = var.logs

  parent_id = azapi_resource.this.id
  application_logs = length(each.value.application_logs) > 0 ? {
    for alk, alv in each.value.application_logs : alk => alv
  }[keys(each.value.application_logs)[0]] : null
  detailed_error_messages = each.value.detailed_error_messages
  failed_requests_tracing = each.value.failed_requests_tracing
  http_logs = length(each.value.http_logs) > 0 ? {
    for hlk, hlv in each.value.http_logs : hlk => hlv
  }[keys(each.value.http_logs)[0]] : null
  ignore_body_changes = var.ignore_body_changes.config_logs
  resource_types      = var.resource_types.config_logs
  retry               = var.retry
  timeouts            = var.timeouts
}
