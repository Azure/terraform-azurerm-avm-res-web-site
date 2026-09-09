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

This output is `sensitive`, matching how the `azurerm` provider treats
`custom_domain_verification_id` on its App Service resources. If you need to
publish it, for example into a DNS TXT record resource whose value is not itself
sensitive, wrap it in `nonsensitive()`.
DESCRIPTION
  sensitive   = true
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

# Compatibility exceptions: polymind-inc/terraform-azurerm-acmebot pins ~> 0.22.0
# and consumes these provider-backed outputs.
output "private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints."
  value       = length(azapi_resource.private_endpoint) > 0 ? azapi_resource.private_endpoint : null
}

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  # tflint-ignore: avm_output_entire_resource_disallowed
  value = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the App Service."
  value       = azapi_resource.this.id
}

output "resource_uri" {
  description = "The default hostname of the resource."
  value       = try(azapi_resource.this.output.properties.defaultHostName, null)
}

output "system_assigned_mi_principal_id" {
  description = "The system-assigned managed identity principal ID."
  value       = try(azapi_resource.this.output.identity.principalId, null)
}

output "system_assigned_mi_principal_id_slots" {
  description = "Map of system-assigned managed identity principal IDs for deployment slots."
  value = {
    for slot_key, slot in module.slot :
    slot_key => slot.identity_principal_id
    if slot.identity_principal_id != null
  }
}
