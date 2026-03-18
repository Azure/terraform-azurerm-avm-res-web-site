output "name" {
  description = "The name of the deploy action."
  value       = "onedeploy"
}

output "resource" {
  description = "The full resource object."
  value       = azapi_resource_action.this
}
