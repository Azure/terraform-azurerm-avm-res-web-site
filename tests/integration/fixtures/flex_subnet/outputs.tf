output "site_id" {
  description = "The deployed site ID."
  value       = module.site.resource_id
}

output "subnet_id" {
  description = "The fixture's integration subnet."
  value       = local.subnet_id
}

output "principal_id" {
  description = "System identity used to detect accidental site replacement."
  value       = module.site.system_assigned_mi_principal_id
}

output "requested_subnet_id" {
  description = "The caller's requested subnet, not a live Azure observation."
  value       = var.attach_subnet ? local.subnet_id : null
}

output "managed_subnet_id" {
  description = "AzAPI's managed body value. A refresh-only plan exposes read/merge behavior, not raw GET or plan actions."
  value       = nonsensitive(try(module.site.resource.body.properties.virtualNetworkSubnetId, null))
}
