output "name" {
  description = "The name of the resource."
  value       = var.os_type == "Windows" ? azurerm_windows_function_app.this[0].name : azurerm_linux_function_app.this[0].name
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = var.os_type == "Windows" ? azurerm_windows_function_app.this[0] : azurerm_linux_function_app.this[0]
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id
}

output "resource_private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
  value       = azurerm_private_endpoint.this
}

output "resource_uri" {
  description = "The default hostname of the resource."
  value       = var.os_type == "Windows" ? azurerm_windows_function_app.this[0].default_hostname : azurerm_linux_function_app.this[0].default_hostname
}
