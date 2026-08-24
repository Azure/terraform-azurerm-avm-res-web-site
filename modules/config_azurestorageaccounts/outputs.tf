output "name" {
  description = "The name of the config resource."
  value       = "azurestorageaccounts"
}

output "resource_id" {
  description = "The resource ID of the config resource."
  value       = "${var.parent_id}/config/azurestorageaccounts"
}
