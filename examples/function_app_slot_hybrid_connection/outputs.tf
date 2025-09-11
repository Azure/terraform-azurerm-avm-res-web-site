output "function_app_id" {
  description = "The ID of the Function App."
  value       = module.avm_res_web_site.function_app_id
}

output "function_app_slot_hybrid_connections" {
  description = "The Function App slot hybrid connections."
  value       = module.avm_res_web_site.function_app_slot_hybrid_connections
}
