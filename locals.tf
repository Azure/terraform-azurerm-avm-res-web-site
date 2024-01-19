# TODO: insert locals here.
locals {
  # resource_group_location            = try(data.azurerm_resource_group.parent.location, null)
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}

# Private endpoint application security group associations
# Remove if this resource does not support private endpoints
locals {

  pe_role_assignments = { for ra in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for rk, rv in pe_v.role_assignments : {
        private_endpoint_key = pe_k
        ra_key               = rk
        role_assignment      = rv
      }
    ]
  ]) : "${ra.private_endpoint_key}-${ra.ra_key}" => ra }

  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
}
