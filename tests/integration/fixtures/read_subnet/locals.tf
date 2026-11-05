locals {
  properties     = data.azapi_resource.site.output.properties
  subnet_present = contains(keys(local.properties), "virtualNetworkSubnetId")
  subnet_value   = try(local.properties.virtualNetworkSubnetId, null)
  detached       = local.subnet_value == null || local.subnet_value == ""
  observation = {
    phase                        = var.phase
    site_id                      = var.site_id
    api_version                  = var.resource_types.web_sites
    subnet_property_present      = local.subnet_present
    subnet_value                 = local.subnet_value
    representation               = !local.subnet_present ? "absent" : local.subnet_value == null ? "null" : local.subnet_value == "" ? "empty_string" : "value"
    detached                     = local.detached
    managed_subnet_after_refresh = var.managed_subnet_after_refresh
    planned_subnet               = var.planned_subnet
  }
}
