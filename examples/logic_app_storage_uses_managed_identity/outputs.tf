output "host_storage_binding" {
  description = "The identity-based host storage settings Azure stored for the Logic App."
  value = {
    credential                   = try(nonsensitive(data.azapi_resource_action.app_settings.sensitive_output.properties.AzureWebJobsStorage__credential), null)
    managed_identity_resource_id = try(nonsensitive(data.azapi_resource_action.app_settings.sensitive_output.properties.AzureWebJobsStorage__managedIdentityResourceId), null)
  }
}

output "location" {
  description = "This is the full output for the resource."
  value       = module.avm_res_web_site.location
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.avm_res_web_site.name
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.avm_res_web_site.resource_id
}

output "storage_account_name" {
  description = "Full output of storage account created"
  value       = azapi_resource.storage_account.name
}
