output "name" {
  description = "The name of the publishing credential policy."
  value       = azapi_update_resource.this.name
}

output "resource" {
  description = "The full resource object."
  # tflint-ignore: no_entire_resource_output_tffr2
  value = azapi_update_resource.this
}

output "resource_id" {
  description = "The resource ID of the publishing credential policy."
  value       = azapi_update_resource.this.id
}
