output "webapp_id" {
  description = "The ID of the App Service."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.app[0].id : azurerm_windows_web_app.app[0].id
}

output "webapp_url" {
  description = "The Default Hostname associated with the App Service."
  value       = var.os_type == "Linux" ? "https://${azurerm_linux_web_app.app[0].default_hostname}" : "https://${azurerm_windows_web_app.app[0].default_hostname}"
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan."
  value       = azurerm_service_plan.asp.id
}

output "principal_id" {
  description = "The Principal ID of the System Assigned Managed Service Identity."
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.app[0].identity[0].principal_id : azurerm_windows_web_app.app[0].identity[0].principal_id
}
