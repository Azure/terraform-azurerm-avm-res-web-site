output "application_insights" {
  description = "The application insights resource."
  value       = var.enable_application_insights ? azurerm_application_insights.this[0] : null
}

output "name" {
  description = "The name of the resource."
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].name : azurerm_linux_function_app.this[0].name) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].name : azurerm_linux_web_app.this[0].name)) : null
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0] : azurerm_linux_function_app.this[0]) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0] : azurerm_linux_web_app.this[0])) : null
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].id : azurerm_linux_function_app.this[0].id) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id)) : null
}

output "resource_private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
  value       = azurerm_private_endpoint.this
}

output "resource_uri" {
  description = "The default hostname of the resource."
  value       = (var.kind == "functionapp" || var.kind == "webapp") ? (var.kind == "functionapp" ? (var.os_type == "Windows" ? azurerm_windows_function_app.this[0].default_hostname : azurerm_linux_function_app.this[0].default_hostname) : (var.os_type == "Windows" ? azurerm_windows_web_app.this[0].default_hostname : azurerm_linux_web_app.this[0].default_hostname)) : null
}

output "service_plan" {
  description = "The service plan resource."
  value       = var.create_service_plan ? azurerm_service_plan.this[0] : null
}

output "storage_account" {
  description = "The storage account resource."
  value       = var.function_app_create_storage_account ? module.avm_res_storage_storageaccount[0] : null
}
