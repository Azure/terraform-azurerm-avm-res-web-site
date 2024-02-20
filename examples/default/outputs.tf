output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  #   value       = azurerm_windows_function_app.this
  value = module.test.resource
}
