output "active_slot" {
  description = "ID of active slot"
  value       = module.avm_res_web_site.web_app_active_slot
}

output "deployment_slots" {
  description = "Full output of deployment slots created"
  sensitive   = true
  value       = module.avm_res_web_site.web_app_deployment_slots
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
  value       = module.avm_res_web_serverfarm.resource_id
}

output "service_plan_name" {
  description = "Full output of service plan created"
  value       = module.avm_res_web_serverfarm.name
}

output "sku_name" {
  description = "The number of workers"
  value       = module.avm_res_web_serverfarm.resource.sku_name
}

output "worker_count" {
  description = "The number of workers"
  value       = module.avm_res_web_serverfarm.resource.worker_count
}

output "zone_redundant" {
  description = "The number of workers"
  value       = module.avm_res_web_serverfarm.resource.zone_balancing_enabled
}
