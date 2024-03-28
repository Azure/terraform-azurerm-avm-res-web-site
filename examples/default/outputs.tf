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

output "storage_account" {
  description = "Full output of storage account created"
  value       = module.test.storage_account
}
