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
  value       = module.avm_res_web_serverfarm.resource_id
}

output "service_plan_name" {
  description = "Full output of service plan created"
  value       = module.avm_res_web_serverfarm.name
}

output "sku_name" {
  description = "The number of workers"
  value       = module.avm_res_web_serverfarm.resource.sku_name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.avm_res_storage_storageaccount.resource_id
}

output "storage_account_kind" {
  description = "The kind of storage account"
  value       = module.avm_res_storage_storageaccount.resource.account_kind
}

output "storage_account_name" {
  description = "Full output of storage account created"
  value       = module.avm_res_storage_storageaccount.name
}

output "storage_account_replication_type" {
  description = "The kind of storage account"
  value       = module.avm_res_storage_storageaccount.resource.account_replication_type
}

output "worker_count" {
  description = "The number of workers"
  value       = module.avm_res_web_serverfarm.resource.worker_count
}

output "zone_redundant" {
  description = "The number of workers"
  value       = module.avm_res_web_serverfarm.resource.zone_balancing_enabled
}
