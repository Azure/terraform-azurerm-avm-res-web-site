output "resource" {
  #   value       = azurerm_windows_function_app.this
  value       = module.test.resource
  description = "This is the full output for the resource."
  sensitive   = true
}