output "active_slot" {
  description = "ID of active slot"
  value       = module.avm_res_web_site.active_slot
}

output "deployment_slots" {
  description = "Full output of deployment slots created"
  sensitive   = true
  value       = module.avm_res_web_site.deployment_slots
}

output "location" {
  description = "This is the full output for the resource."
  value       = module.avm_res_web_site.location
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.avm_res_web_site.name
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.avm_res_web_site.resource_id
}

output "service_plan_id" {
  description = "The ID of the app service"
  value       = azapi_resource.service_plan.id
}

output "service_plan_name" {
  description = "Full output of service plan created"
  value       = azapi_resource.service_plan.name
}
