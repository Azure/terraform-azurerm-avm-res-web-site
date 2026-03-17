output "resource" {
  description = "The full resource object."
  value       = azapi_resource_action.this
}

output "resource_id" {
  description = "The resource ID of the config resource."
  value       = azapi_resource_action.this.resource_id
}
