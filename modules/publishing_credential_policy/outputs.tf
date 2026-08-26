output "name" {
  description = "The name of the publishing credential policy."
  value       = azapi_update_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the publishing credential policy."
  value       = azapi_update_resource.this.id
}
