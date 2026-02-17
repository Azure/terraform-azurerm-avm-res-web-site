# schema_validation_enabled = false is needed because Cap_DailyDataVolumeInGB and
# Cap_DailyDataVolumeNotificationDisabled are valid ARM properties but not in the
# azapi provider's embedded schema for the 2020-02-02 API version.

locals {
  application_insights_instances = merge(
    var.enable_application_insights ? { main = var.application_insights } : {},
    var.slot_application_insights,
  )
}

resource "azapi_resource" "application_insights" {
  for_each = local.application_insights_instances

  location  = coalesce(each.value.location, var.location)
  name      = coalesce(each.value.name, each.key == "main" ? "ai-${var.name}" : "ai-${var.name}-${each.key}")
  parent_id = coalesce(each.value.parent_id, var.parent_id)
  type      = "Microsoft.Insights/components@2020-02-02"
  body = {
    kind = each.value.application_type
    properties = {
      Application_Type                        = each.value.application_type
      WorkspaceResourceId                     = each.value.workspace_resource_id
      RetentionInDays                         = each.value.retention_in_days
      SamplingPercentage                      = each.value.sampling_percentage
      DisableIpMasking                        = each.value.disable_ip_masking
      DisableLocalAuth                        = each.value.local_authentication_disabled
      IngestionMode                           = each.value.workspace_resource_id != null ? "LogAnalytics" : "ApplicationInsights"
      publicNetworkAccessForIngestion         = each.value.internet_ingestion_enabled ? "Enabled" : "Disabled"
      publicNetworkAccessForQuery             = each.value.internet_query_enabled ? "Enabled" : "Disabled"
      ForceCustomerStorageForProfiler         = each.value.force_customer_storage_for_profiler
      Cap_DailyDataVolumeInGB                 = each.value.daily_data_cap_in_gb
      Cap_DailyDataVolumeNotificationDisabled = each.value.daily_data_cap_notifications_disabled
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = [
    "properties.ConnectionString",
    "properties.InstrumentationKey",
  ]
  schema_validation_enabled = false
  tags                      = each.value.inherit_tags ? merge(var.tags, each.value.tags) : each.value.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
