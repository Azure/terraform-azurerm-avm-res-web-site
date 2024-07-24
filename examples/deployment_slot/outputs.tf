output "active_slot" {
  description = "ID of active slot"
  value       = module.test.kind == "functionapp" ? module.test.function_app_active_slot : module.test.web_app_active_slot
}

output "deployment_slots" {
  description = "Full output of deployment slots created"
  sensitive   = true
  value       = module.test.function_app_deployment_slots
}

output "kind" {
  value = module.test.kind
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.test.name
}

output "os_type" {
  value = module.test.os_type
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

output "storage_account" {
  description = "Full output of storage account created"
  sensitive   = true
  value       = module.test.storage_account
}
