output "web_app_id" {
  description = "The ID of the Web App."
  value       = module.avm_res_web_site.web_app_id
}

output "web_app_slot_hybrid_connections" {
  description = "The Web App slot hybrid connections."
  value       = module.avm_res_web_site.web_app_slot_hybrid_connections
}
