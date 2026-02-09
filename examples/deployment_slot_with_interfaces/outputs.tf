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

output "service_plan_id" {
  description = "The ID of the app service"
  value       = azapi_resource.service_plan.id
}

output "service_plan_name" {
  description = "Full output of service plan created"
  value       = azapi_resource.service_plan.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azapi_resource.storage_account.id
}

output "storage_account_name" {
  description = "Full output of storage account created"
  value       = azapi_resource.storage_account.name
}

output "system_assigned_mi_principal_id" {
  description = "Test"
  value       = module.avm_res_web_site.system_assigned_mi_principal_id
}

output "system_assigned_mi_principal_id_slots" {
  description = "Test"
  value       = module.avm_res_web_site.system_assigned_mi_principal_id_slots
}
