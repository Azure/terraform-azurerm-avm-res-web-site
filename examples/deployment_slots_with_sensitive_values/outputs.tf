output "web_app_name" {
  description = "The name of the primary web app"
  value       = module.avm_res_web_site.name
}

output "web_app_id" {
  description = "The resource ID of the primary web app"
  value       = module.avm_res_web_site.resource_id
}

output "web_app_default_hostname" {
  description = "The default hostname of the primary web app"
  value       = module.avm_res_web_site.resource_uri
}

output "deployment_slot_names" {
  description = "The names of all deployment slots (non-sensitive)"
  value       = keys(module.avm_res_web_site.web_app_deployment_slots)
}

output "staging_slot_id" {
  description = "The resource ID of the staging deployment slot"
  value       = module.avm_res_web_site.web_app_deployment_slots["staging"].id
}

output "production_slot_id" {
  description = "The resource ID of the production deployment slot"
  value       = module.avm_res_web_site.web_app_deployment_slots["production"].id
}

output "staging_slot_hostname" {
  description = "The hostname of the staging deployment slot"
  value       = module.avm_res_web_site.web_app_deployment_slots["staging"].default_hostname
}

output "production_slot_hostname" {
  description = "The hostname of the production deployment slot"
  value       = module.avm_res_web_site.web_app_deployment_slots["production"].default_hostname
}

# Note: We DO NOT output sensitive values like connection strings or API keys
# These remain protected and should be accessed securely from the deployed application
