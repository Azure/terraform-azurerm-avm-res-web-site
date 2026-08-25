output "name" {
  description = "The name of the deploy action."
  value       = "onedeploy"
}

output "resource" {
  description = "The full resource object."
  # tflint-ignore: no_entire_resource_output_tffr2
  value = azapi_resource_action.this
}
