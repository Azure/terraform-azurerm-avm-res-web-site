output "active_slot" {
  description = "The active slot resource ID."
  value       = var.app_service_active_slot != null ? azapi_resource_action.active_slot[0].id : azapi_resource.this.id
}

output "custom_domain_verification_id" {
  description = <<DESCRIPTION
The custom domain verification ID for the App Service. Use this value to create
an `asuid.<custom-hostname>` TXT record in your DNS zone before binding a custom
domain via `var.custom_domains`. See the `custom_domains` variable documentation
for details on the DNS prerequisites that Azure enforces.
DESCRIPTION
  value       = try(azapi_resource.this.output.properties.customDomainVerificationId, null)
}

output "deployment_slots" {
  description = "A map of deployment slots with their names and resource IDs. The map key is the supplied input to var.deployment_slots."
  value = length(module.slot) > 0 ? {
    for k, v in module.slot : k => {
      name        = v.name
      resource_id = v.resource_id
    }
  } : null
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

# Compatibility exception: polymind-inc/terraform-azurerm-acmebot pins ~> 0.22.0
# and re-exports this value.
output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  # tflint-ignore: no_entire_resource_output_tffr2
  value = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the App Service."
  sensitive   = true
  value       = azapi_resource.this.id
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
    for slot_key, slot in module.slot :
    slot_key => slot.identity_principal_id
    if slot.identity_principal_id != null
  }
}
