output "application_insights" {
  description = "The application insights resource."
  value       = var.enable_application_insights ? azurerm_application_insights.this[0] : null
}

output "deployment_slot_locks" {
  description = "The locks of the deployment slots."
  value       = azurerm_management_lock.slot != null ? azurerm_management_lock.slot : null
}

output "function_app_active_slot" {
  description = "The active slot."
  value       = var.kind == "functionapp" && var.app_service_active_slot != null ? azurerm_function_app_active_slot.this[0].id : (var.kind == "functionapp" && var.app_service_active_slot == null && var.os_type == "Windows") ? azurerm_windows_function_app.this[0].id : var.kind == "functionapp" && var.app_service_active_slot == null && var.os_type == "Linux" ? azurerm_linux_function_app.this[0].id : null
}

output "function_app_deployment_slots" {
  description = "The deployment slots."
  value       = var.kind == "functionapp" && var.os_type == "Windows" && var.deployment_slots != null ? azurerm_windows_function_app_slot.this : azurerm_linux_function_app_slot.this
}

output "identity_principal_id" {
  description = "The object principal id of the resource."
  sensitive   = true
  value       = var.kind == "functionapp" ? (var.os_type == "Windows" ? (length(azurerm_windows_function_app.this[0].identity) > 0 ? azurerm_windows_function_app.this[0].identity[0].principal_id : null) : length(azurerm_linux_function_app.this[0].identity) > 0 ? azurerm_linux_function_app.this[0].identity[0].principal_id : null) : (var.os_type == "Windows" ? (length(azurerm_windows_web_app.this[0].identity) > 0 ? azurerm_windows_web_app.this[0].identity[0].principal_id : null) : length(azurerm_linux_web_app.this[0].identity) > 0 ? azurerm_linux_web_app.this[0].identity[0].principal_id : null)
}

output "kind" {
  description = "The kind of app service."
  value       = var.kind
}

output "location" {
  description = "The location of the resource."
  value       = var.location
}

output "name" {
  description = "The name of the resource."
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].name : azurerm_linux_function_app.this[0].name) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].name : azurerm_linux_web_app.this[0].name)) : null
}

output "os_type" {
  description = "The operating system type of the resource."
  value       = var.os_type
}

output "private_endpoint_locks" {
  description = "The locks of the deployment slots."
  value       = azurerm_management_lock.pe != null ? azurerm_management_lock.pe : null
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0] : azurerm_linux_function_app.this[0]) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0] : azurerm_linux_web_app.this[0])) : null
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id)) : null
}

output "resource_lock" {
  description = "The locks of the resources."
  value       = azurerm_management_lock.this != null ? azurerm_management_lock.this : null
}

output "resource_private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "resource_uri" {
  description = "The default hostname of the resource."
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].default_hostname : azurerm_linux_function_app.this[0].default_hostname) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].default_hostname : azurerm_linux_web_app.this[0].default_hostname)) : null
}

output "system_assigned_mi_principal_id" {
  description = "value"
  sensitive   = true
  value       = var.kind == "functionapp" ? (var.os_type == "Windows" ? (length(azurerm_windows_function_app.this[0].identity) > 0 ? azurerm_windows_function_app.this[0].identity[0].principal_id : null) : length(azurerm_linux_function_app.this[0].identity) > 0 ? azurerm_linux_function_app.this[0].identity[0].principal_id : null) : (var.os_type == "Windows" ? (length(azurerm_windows_web_app.this[0].identity) > 0 ? azurerm_windows_web_app.this[0].identity[0].principal_id : null) : length(azurerm_linux_web_app.this[0].identity) > 0 ? azurerm_linux_web_app.this[0].identity[0].principal_id : null)
}

output "system_assigned_mi_principal_id_slots" {
  description = "Map or value of system-assigned managed identity principal IDs for resources slots"
  sensitive   = true
  value = var.kind == "functionapp" ? (
    var.os_type == "Windows" ? (
      length(azurerm_windows_function_app_slot.this) > 0 ?
      { for slot_key, slot_resource in azurerm_windows_function_app_slot.this : slot_key => try(slot_resource.identity[0].principal_id, null) } : {}
    ) : length(azurerm_linux_function_app_slot.this) > 0 ?
    { for slot_key, slot_resource in azurerm_linux_function_app_slot.this : slot_key => try(slot_resource.identity[0].principal_id, null) } : {}
    ) : (
    var.os_type == "Windows" ? (
      length(azurerm_windows_web_app_slot.this) > 0 ?
      { for slot_key, slot_resource in azurerm_windows_web_app_slot.this : slot_key => try(slot_resource.identity[0].principal_id, null) } : {}
    ) : length(azurerm_linux_web_app_slot.this) > 0 ?
    { for slot_key, slot_resource in azurerm_linux_web_app_slot.this : slot_key => try(slot_resource.identity[0].principal_id, null) } : {}
  )
}

output "thumbprints" {
  description = "The thumbprint of the certificate."
  sensitive   = true
  value       = azurerm_app_service_certificate.this != null ? azurerm_app_service_certificate.this : null
}

output "web_app_active_slot" {
  description = "The active slot."
  value       = var.kind == "webapp" && var.app_service_active_slot != null ? azurerm_web_app_active_slot.this[0].id : (var.kind == "webapp" && var.app_service_active_slot == null && var.os_type == "Windows") ? azurerm_windows_web_app.this[0].id : var.kind == "webapp" && var.app_service_active_slot == null && var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : null
}

output "web_app_deployment_slots" {
  description = "The deployment slots."
  value       = var.kind == "webapp" && var.os_type == "Windows" && var.deployment_slots != null ? azurerm_windows_web_app_slot.this : azurerm_linux_web_app_slot.this
}
