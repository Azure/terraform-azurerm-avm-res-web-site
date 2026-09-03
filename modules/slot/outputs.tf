output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity (if enabled)."
  value       = try(azapi_resource.this.output.identity.principalId, null)
}

output "name" {
  description = "The name of the deployment slot."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the deployment slot."
  value       = azapi_resource.this.id
}

output "server_farm_resource_id" {
  description = "The normalized service plan resource ID configured on the deployment slot."
  value       = azapi_resource.this.body.properties.serverFarmId
}
