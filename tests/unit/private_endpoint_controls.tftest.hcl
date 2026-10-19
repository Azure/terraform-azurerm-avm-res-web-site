mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
    }
  }
  mock_data "azapi_resource_list" {
    defaults = {
      output = { results = [] }
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "11111111-1111-4111-8111-111111111111"
    }
  }
}

mock_provider "time" {}

override_resource {
  target = azapi_resource.private_endpoint["configured"]
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/privateEndpoints/configured"
  }
}

variables {
  enable_telemetry         = false
  location                 = "eastus"
  name                     = "unit-test-site"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "site_endpoint_controls_reach_arm_bodies" {
  command = apply

  variables {
    private_endpoints = {
      configured = {
        name                            = "configured"
        subnet_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name                = "sites-blue"
        private_service_connection_name = "configured-connection"
        network_interface_name          = "configured-nic"
        lock = {
          kind  = "CanNotDelete"
          name  = "configured-lock"
          notes = "Keep this endpoint."
        }
        role_assignments = {
          reader = {
            name                                   = "22222222-2222-4222-8222-222222222222"
            role_definition_id_or_name             = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/33333333-3333-4333-8333-333333333333"
            principal_id                           = "44444444-4444-4444-8444-444444444444"
            principal_type                         = "ServicePrincipal"
            description                            = "Endpoint reader"
            condition                              = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals 'example'"
            condition_version                      = "2.0"
            delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
          }
        }
        ip_configurations = {
          custom = {
            name               = "custom-ip"
            private_ip_address = "10.0.0.4"
            member_name        = "custom-member"
          }
          default_member = {
            name               = "default-ip"
            private_ip_address = "10.0.0.5"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.private_endpoint["configured"].name == "configured" &&
      azapi_resource.private_endpoint["configured"].body.properties.privateLinkServiceConnections[0].name == "configured-connection" &&
      azapi_resource.private_endpoint["configured"].body.properties.privateLinkServiceConnections[0].properties.groupIds == ["sites-blue"] &&
      azapi_resource.private_endpoint["configured"].body.properties.privateLinkServiceConnections[0].properties.privateLinkServiceId == azapi_resource.this.id &&
      azapi_resource.private_endpoint["configured"].body.properties.customNetworkInterfaceName == "configured-nic" &&
      alltrue([for ip in azapi_resource.private_endpoint["configured"].body.properties.ipConfigurations : ip.properties.groupId == "sites-blue"]) &&
      azapi_resource.private_endpoint["configured"].body.properties.ipConfigurations[0].properties.memberName == "custom-member" &&
      azapi_resource.private_endpoint["configured"].body.properties.ipConfigurations[1].properties.memberName == "default"
    )
    error_message = "Site endpoint names, service scope, subresource and custom/default IP members must reach ARM."
  }
  assert {
    condition = (
      azapi_resource.lock_private_endpoint["configured"].name == "configured-lock" &&
      azapi_resource.lock_private_endpoint["configured"].parent_id == azapi_resource.private_endpoint["configured"].id &&
      azapi_resource.lock_private_endpoint["configured"].body.properties.level == "CanNotDelete" &&
      azapi_resource.lock_private_endpoint["configured"].body.properties.notes == "Keep this endpoint."
    )
    error_message = "The endpoint lock must retain its name, scope, level and notes."
  }
  assert {
    condition = (
      azapi_resource.role_assignment_private_endpoint["configured-reader"].name == "22222222-2222-4222-8222-222222222222" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].parent_id == azapi_resource.private_endpoint["configured"].id &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.principalId == var.private_endpoints["configured"].role_assignments["reader"].principal_id &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.roleDefinitionId == var.private_endpoints["configured"].role_assignments["reader"].role_definition_id_or_name &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.principalType == "ServicePrincipal" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.description == "Endpoint reader" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.condition == var.private_endpoints["configured"].role_assignments["reader"].condition &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.conditionVersion == "2.0" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.delegatedManagedIdentityResourceId == var.private_endpoints["configured"].role_assignments["reader"].delegated_managed_identity_resource_id
    )
    error_message = "Assignment UUIDs must survive without changing scope, principal, role or permission conditions."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "site_endpoint_defaults_remain_unchanged" {
  command = apply

  variables {
    private_endpoints = {
      configured = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = null
        lock = {
          kind  = "ReadOnly"
          name  = "default-lock"
          notes = null
        }
        role_assignments = {
          reader = {
            name                       = null
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/33333333-3333-4333-8333-333333333333"
            principal_id               = "44444444-4444-4444-8444-444444444444"
          }
        }
      }
      omitted = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
      }
    }
  }

  assert {
    condition = alltrue([
      for endpoint in azapi_resource.private_endpoint :
      endpoint.body.properties.privateLinkServiceConnections[0].properties.groupIds == ["sites"] &&
      endpoint.name == "pep-sites-${uuidv5("url", azapi_resource.this.id)}" &&
      endpoint.body.properties.privateLinkServiceConnections[0].name == "pcon-pep-sites-${uuidv5("url", azapi_resource.this.id)}" &&
      endpoint.body.properties.customNetworkInterfaceName == "nic-pep-sites-${uuidv5("url", azapi_resource.this.id)}"
    ])
    error_message = "Omitted and null subresources must preserve the sites group and existing generated names."
  }
  assert {
    condition = (
      azapi_resource.role_assignment_private_endpoint["configured-reader"].name == "11111111-1111-4111-8111-111111111111" &&
      azapi_resource.lock_private_endpoint["configured"].body.properties.notes == null &&
      length(azapi_resource.lock_private_endpoint) == 1 &&
      length(azapi_resource.role_assignment_private_endpoint) == 1
    )
    error_message = "Null assignment names must use the existing UUID generator and null notes must remain optional."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "site_endpoint_dns_management_can_remain_external" {
  command = apply

  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      configured = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        private_dns_zone_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"]
      }
    }
  }
  assert {
    condition     = length(azapi_resource.private_endpoint) == 1 && length(azapi_resource.private_dns_zone_group) == 0
    error_message = "Disabling DNS management must keep one endpoint and create no managed zone group."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "deployment_slot_endpoint_schema_preserves_controls" {
  command = apply

  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  variables {
    deployment_slots = {
      staging = {
        private_endpoints = {
          configured = {
            subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
            subresource_name   = "sites-custom"
            lock = {
              kind  = "CanNotDelete"
              name  = "slot-lock"
              notes = "Slot endpoint notes"
            }
            role_assignments = {
              reader = {
                name                       = "22222222-2222-4222-8222-222222222222"
                role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/33333333-3333-4333-8333-333333333333"
                principal_id               = "44444444-4444-4444-8444-444444444444"
              }
            }
            ip_configurations = {
              custom = {
                name               = "custom-ip"
                private_ip_address = "10.0.0.4"
                member_name        = "custom-member"
              }
            }
          }
        }
      }
    }
  }
  assert {
    condition = (
      var.deployment_slots["staging"].private_endpoints["configured"].subresource_name == "sites-custom" &&
      var.deployment_slots["staging"].private_endpoints["configured"].lock.notes == "Slot endpoint notes" &&
      var.deployment_slots["staging"].private_endpoints["configured"].role_assignments["reader"].name == "22222222-2222-4222-8222-222222222222" &&
      var.deployment_slots["staging"].private_endpoints["configured"].ip_configurations["custom"].member_name == "custom-member"
    )
    error_message = "The deployment_slots input must not discard endpoint controls before calling the slot."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
