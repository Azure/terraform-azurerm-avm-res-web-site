output "web_app_name" {
  description = "The name of the deployed App Service."
  value       = module.avm_res_web_site.name
}

output "web_app_uri" {
  description = "The default hostname of the App Service."
  value       = module.avm_res_web_site.resource_uri
}

output "key_vault_name" {
  description = "The Key Vault holding the AAD client secret."
  value       = azurerm_key_vault.this.name
}