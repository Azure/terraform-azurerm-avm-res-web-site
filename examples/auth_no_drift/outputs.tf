output "resource_group_name" {
  description = "The name of the resource group created for this POC."
  value       = azurerm_resource_group.this.name
}

output "web_app_name" {
  description = "The name of the deployed App Service web app."
  value       = module.avm_res_web_site.name
}

output "web_app_default_hostname" {
  description = "The default hostname of the App Service."
  value       = module.avm_res_web_site.resource_uri
}

output "key_vault_name" {
  description = "The name of the Key Vault holding auth secrets."
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "application_insights_name" {
  description = "The name of the Application Insights resource."
  value       = azurerm_application_insights.this.name
}

output "application_insights_app_id" {
  description = "The App ID of the Application Insights resource."
  value       = azurerm_application_insights.this.app_id
}

output "user_assigned_identity_id" {
  description = "Resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "user_assigned_identity_client_id" {
  description = "Client ID of the user-assigned managed identity (needed for Key Vault reference setup)."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "region" {
  description = "The Azure region where all resources were deployed."
  value       = azurerm_resource_group.this.location
}

output "random_region_index" {
  description = "The pinned index into local.azure_regions. This value is FROZEN by keepers and will not change on re-runs."
  value       = random_integer.region_index.result
}
