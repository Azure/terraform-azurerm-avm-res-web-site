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
  value       = azurerm_service_plan.example.id
}

output "service_plan_name" {
  description = "Full output of service plan created"
  value       = azurerm_service_plan.example.name
}

output "sku_name" {
  description = "The number of workers"
  value       = azurerm_service_plan.example.sku_name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.example.id
}

output "storage_account_kind" {
  description = "The kind of storage account"
  value       = azurerm_storage_account.example.account_kind
}

output "storage_account_name" {
  description = "Full output of storage account created"
  value       = azurerm_storage_account.example.name
}

output "storage_account_replication_type" {
  description = "The kind of storage account"
  value       = azurerm_storage_account.example.account_replication_type
}

output "system_assigned_mi_principal_id" {
  description = "Test"
  value       = module.avm_res_web_site.system_assigned_mi_principal_id
}

output "system_assigned_mi_principal_id_slots" {
  description = "Test"
  value       = module.avm_res_web_site.system_assigned_mi_principal_id_slots
}

output "worker_count" {
  description = "The number of workers"
  value       = azurerm_service_plan.example.worker_count
}

output "zone_redundant" {
  description = "The number of workers"
  value       = azurerm_service_plan.example.zone_balancing_enabled
}
