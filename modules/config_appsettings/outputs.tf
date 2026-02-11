output "name" {
  description = "The name of the config resource."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full resource object."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the config resource."
  value       = azapi_resource.this.id
}
