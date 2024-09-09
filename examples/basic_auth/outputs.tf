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
