output "app_settings" {
  description = "The app settings written to the site, as sent to ARM."
  # App settings routinely carry connection strings and storage account keys.
  sensitive = true
  value     = azapi_update_resource.this.body.properties
}

output "name" {
  description = "The name of the config resource."
  value       = azapi_update_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the config resource."
  value       = azapi_update_resource.this.id
}
