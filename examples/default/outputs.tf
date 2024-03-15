output "name" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.name
}

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.resource
}
