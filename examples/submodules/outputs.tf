output "appsettings" {
  description = "The app settings submodule output."
  value       = module.appsettings.name
}

output "connectionstrings" {
  description = "The connection strings submodule output."
  value       = module.connectionstrings.name
}

output "location" {
  description = "The location of the web app."
  value       = module.avm_res_web_site.location
}

output "logs" {
  description = "The logs submodule output."
  value       = module.logs.name
}

output "name" {
  description = "The name of the web app."
  value       = module.avm_res_web_site.name
}

output "resource_id" {
  description = "The resource ID of the web app."
  sensitive   = true
  value       = module.avm_res_web_site.resource_id
}

output "service_plan_id" {
  description = "The ID of the app service plan."
  value       = azapi_resource.service_plan.id
}

output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azapi_resource.storage_account.id
}
