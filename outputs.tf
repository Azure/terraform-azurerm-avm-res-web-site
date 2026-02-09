output "active_slot" {
  description = "The active slot resource ID."
  value       = var.app_service_active_slot != null ? azapi_resource_action.active_slot[0].id : azapi_resource.this.id
}

output "application_insights" {
  description = "The application insights resource."
  value       = var.enable_application_insights ? azapi_resource.application_insights[0] : null
}

output "deployment_slot_locks" {
  description = "The locks of the deployment slots."
  value       = length(azapi_resource.slot_lock) > 0 ? azapi_resource.slot_lock : null
}

output "deployment_slots" {
  description = "The deployment slots."
  value       = length(azapi_resource.slot) > 0 ? azapi_resource.slot : null
}

output "identity_principal_id" {
  description = "The system-assigned managed identity principal ID of the resource."
  sensitive   = true
  value       = try(azapi_resource.this.output.identity.principalId, null)
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
  value       = azapi_resource.this.name
}

output "os_type" {
  description = "The operating system type of the resource."
  value       = var.os_type
}

output "private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints."
  value       = length(azapi_resource.private_endpoint) > 0 ? azapi_resource.private_endpoint : null
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the App Service."
  sensitive   = true
  value       = azapi_resource.this.id
}

output "resource_lock" {
  description = "The locks of the resources."
  value       = length(azapi_resource.lock) > 0 ? azapi_resource.lock : null
}

output "resource_private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azapi_resource."
  value       = length(azapi_resource.private_endpoint) > 0 ? azapi_resource.private_endpoint : null
}

output "resource_uri" {
  description = "The default hostname of the resource."
  value       = try(azapi_resource.this.output.properties.defaultHostName, null)
}

output "system_assigned_mi_principal_id" {
  description = "The system-assigned managed identity principal ID."
  sensitive   = true
  value       = try(azapi_resource.this.output.identity.principalId, null)
}

output "system_assigned_mi_principal_id_slots" {
  description = "Map of system-assigned managed identity principal IDs for deployment slots."
  sensitive   = true
  value = {
    for slot_key, slot in azapi_resource.slot :
    slot_key => try(slot.output.identity.principalId, null)
    if try(slot.output.identity.principalId, null) != null
  }
}
