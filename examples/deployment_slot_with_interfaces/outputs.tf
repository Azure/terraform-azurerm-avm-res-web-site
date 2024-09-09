output "active_slot" {
  description = "ID of active slot"
  value       = module.test.web_app_active_slot
}

output "deployment_slot_locks" {
  description = "The locks of the deployment slots."
  value       = module.test.deployment_slot_locks
}

output "deployment_slots" {
  description = "Full output of deployment slots created"
  sensitive   = true
  value       = module.test.web_app_deployment_slots
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.test.name
}

output "private_endpoint_locks" {
  description = "The locks of the deployment slots."
  value       = module.test.private_endpoint_locks
}

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.resource
}

output "resource_lock" {
  description = "The locks of the resources."
  value       = module.test.resource_lock
}

output "storage_account" {
  description = "Full output of storage account created"
  sensitive   = true
  value       = module.test.storage_account
}

output "storage_account_lock" {
  description = "The lock of the storage account."
  value       = module.test.storage_account_lock
}
