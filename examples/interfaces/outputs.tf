output "identity_principal_id" {
  description = "The principal ID for the identity."
  sensitive   = true
  value       = module.avm_res_web_site.identity_principal_id
}

output "name" {
  description = "Name for the resource."
  value       = module.avm_res_web_site.name
}

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.avm_res_web_site.resource
}

output "resource_uri" {
  description = "This is the URI for the resource."
  value       = module.avm_res_web_site.resource_uri
}
