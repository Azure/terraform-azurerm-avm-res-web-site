output "location" {
  description = "This is the full output for the resource."
  value       = module.test.location
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.test.name
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.resource_id
}

output "service_plan_id" {
  description = "The ID of the app service"
  value       = module.test.service_plan_id
}

output "service_plan_name" {
  description = "Full output of service plan created"
  value       = module.test.service_plan_name
}

output "sku_name" {
  description = "The number of workers"
  value       = module.test.service_plan.sku_name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.test.storage_account.resource_id
}

output "storage_account_name" {
  description = "Full output of storage account created"
  value       = module.test.storage_account.name
}

output "worker_count" {
  description = "The number of workers"
  value       = module.test.service_plan.worker_count
}

output "zone_redundant" {
  description = "The number of workers"
  value       = module.test.service_plan.zone_balancing_enabled
}
