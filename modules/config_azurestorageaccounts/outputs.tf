output "name" {
  description = "The name of the config resource."
  value       = "azurestorageaccounts"
}

output "resource" {
  description = "The full resource object."
  # tflint-ignore: no_entire_resource_output_tffr2
  value = azapi_resource_action.this
}

output "resource_id" {
  description = "The resource ID of the config resource."
  value       = "${var.parent_id}/config/azurestorageaccounts"
}
