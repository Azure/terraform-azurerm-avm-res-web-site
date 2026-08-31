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

# Compatibility exception: `system_assigned_mi_principal_id` is the name RMFR7
# prescribes, but this alias predates it and published configurations pinned to
# earlier releases consume it. See "Deprecated outputs" in the README.
output "identity_principal_id" {
  description = <<DESCRIPTION
Deprecated alias for `system_assigned_mi_principal_id`. Both outputs evaluate
the same expression: the principal ID of the site's system-assigned managed
identity, or `null` when the site has none.

AVM prescribes `system_assigned_mi_principal_id` as the Terraform name for this
output ([RMFR7](https://azure.github.io/Azure-Verified-Modules/spec/RMFR7)), so
new configurations should use that name. This alias is retained for existing
consumers; removing it would be a breaking change and would be announced as
one.
DESCRIPTION
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
  # tflint-ignore: no_entire_resource_output_tffr2
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
  description = <<DESCRIPTION
The principal ID of the site's system-assigned managed identity, or `null` when
the site has none.

This is the output name AVM prescribes
([RMFR7](https://azure.github.io/Azure-Verified-Modules/spec/RMFR7)). Prefer it
over the deprecated `identity_principal_id` alias.
DESCRIPTION
  value       = try(azapi_resource.this.output.identity.principalId, null)
}

output "system_assigned_mi_principal_id_slots" {
  description = "Map of system-assigned managed identity principal IDs for deployment slots."
  # Sourced from the `slot` submodule's own `identity_principal_id` output,
  # which is that module's only name for the value and is not deprecated.
  value = {
    for slot_key, slot in module.slot :
    slot_key => slot.identity_principal_id
    if slot.identity_principal_id != null
  }
}
