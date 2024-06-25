output "identity_principal_id" {
  description = "The principal ID for the identity."
  sensitive   = true
  value       = module.test.identity_principal_id
}

output "name" {
  description = "Name for the resource."
  value       = module.test.name
}

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.resource
}

output "resource_uri" {
  description = "This is the URI for the resource."
  value       = module.test.resource_uri
}
