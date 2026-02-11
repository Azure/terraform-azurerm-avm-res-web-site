# Moved blocks for migrating slot interface resources to the avm_interfaces module pattern.

# Lock changed from count to for_each (keyed by "lock")
moved {
  from = azapi_resource.lock[0]
  to   = azapi_resource.lock["lock"]
}

# Private endpoint locks renamed to match root module pattern
moved {
  from = azapi_resource.pe_lock
  to   = azapi_resource.lock_private_endpoint
}

# Private endpoint role assignments renamed to match root module pattern
moved {
  from = azapi_resource.pe_role_assignment
  to   = azapi_resource.role_assignment_private_endpoint
}
