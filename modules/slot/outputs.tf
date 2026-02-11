output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity (if enabled)."
  value       = try(azapi_resource.this.output.identity.principalId, null)
}

output "lock" {
  description = "The lock resource for this slot."
  value       = one(values(azapi_resource.lock))
}

output "name" {
  description = "The name of the deployment slot."
  value       = azapi_resource.this.name
}

output "private_endpoints" {
  description = "The private endpoints created for this slot."
  value       = azapi_resource.private_endpoint
}

output "resource" {
  description = "The full slot resource object."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the deployment slot."
  value       = azapi_resource.this.id
}
