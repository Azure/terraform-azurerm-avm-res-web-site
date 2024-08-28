output "location" {
  description = "This is the full output for the resource."
  value       = module.test.location
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.test.name
}

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.resource
}

output "service_plan" {
  description = "Full output of service plan created"
  value       = module.test.service_plan
}

output "sku_name" {
  description = "The SKU of the app service"
  value       = module.test.sku_name
}

output "storage_account" {
  description = "Full output of storage account created"
  sensitive   = true
  value       = module.test.storage_account
}

output "worker_count" {
  description = "The number of workers in the service plan"
  value       = module.test.worker_count
}

output "zone_redundant" {
  description = "The zone redundancy of the app service"
  value       = module.test.zone_redundant
}
