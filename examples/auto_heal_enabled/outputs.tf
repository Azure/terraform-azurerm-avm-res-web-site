output "active_slot" {
  description = "ID of active slot"
  value       = module.test.web_app_active_slot
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

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.resource
}

output "storage_account" {
  description = "Full output of storage account created"
  sensitive   = true
  value       = module.test.storage_account
}
