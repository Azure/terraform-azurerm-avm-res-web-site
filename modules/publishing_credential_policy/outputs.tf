output "name" {
  description = "The name of the publishing credential policy."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full resource object."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the publishing credential policy."
  value       = azapi_resource.this.id
}
