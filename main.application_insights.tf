# Application Insights resource (Microsoft.Insights/components)
# schema_validation_enabled = false is needed because Cap_DailyDataVolumeInGB and
# Cap_DailyDataVolumeNotificationDisabled are valid ARM properties but not in the
# azapi provider's embedded schema for the 2020-02-02 API version.
resource "azapi_resource" "application_insights" {
  count = var.enable_application_insights ? 1 : 0

  location  = coalesce(var.application_insights.location, var.location)
  name      = coalesce(var.application_insights.name, "ai-${var.name}")
  parent_id = "/subscriptions/${local.subscription_id}/resourceGroups/${coalesce(var.application_insights.resource_group_name, var.resource_group_name)}"
  type      = "Microsoft.Insights/components@2020-02-02"
  body = {
    kind = var.application_insights.application_type
    properties = {
      Application_Type                        = var.application_insights.application_type
      WorkspaceResourceId                     = var.application_insights.workspace_resource_id
      RetentionInDays                         = var.application_insights.retention_in_days
      SamplingPercentage                      = var.application_insights.sampling_percentage
      DisableIpMasking                        = var.application_insights.disable_ip_masking
      DisableLocalAuth                        = var.application_insights.local_authentication_disabled
      IngestionMode                           = var.application_insights.workspace_resource_id != null ? "LogAnalytics" : "ApplicationInsights"
      publicNetworkAccessForIngestion         = var.application_insights.internet_ingestion_enabled ? "Enabled" : "Disabled"
      publicNetworkAccessForQuery             = var.application_insights.internet_query_enabled ? "Enabled" : "Disabled"
      ForceCustomerStorageForProfiler         = var.application_insights.force_customer_storage_for_profiler
      Cap_DailyDataVolumeInGB                 = var.application_insights.daily_data_cap_in_gb
      Cap_DailyDataVolumeNotificationDisabled = var.application_insights.daily_data_cap_notifications_disabled
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
  tags                      = var.application_insights.inherit_tags ? merge(var.tags, var.application_insights.tags) : var.application_insights.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Slot Application Insights resources
resource "azapi_resource" "slot_application_insights" {
  for_each = { for k, v in var.slot_application_insights : k => v }

  location  = coalesce(each.value.location, var.location)
  name      = coalesce(each.value.name, "ai-${var.name}-${each.key}")
  parent_id = "/subscriptions/${local.subscription_id}/resourceGroups/${coalesce(each.value.resource_group_name, var.resource_group_name)}"
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
