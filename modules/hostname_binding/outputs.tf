output "name" {
  description = "The hostname binding name."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full resource object."
  # tflint-ignore: no_entire_resource_output_tffr2
  value = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the hostname binding."
  value       = azapi_resource.this.id
}
