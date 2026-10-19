mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
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
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/privateEndpoints/slot-configured"
  }
}

variables {
  kind                     = "webapp"
  location                 = "eastus"
  name                     = "staging"
  os_type                  = "Windows"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

# Bind the transitive ModTM mock to Azure/modtm without changing caller inheritance.
run "bind_transitive_mock_provider_source" {
  command = apply

  module {
    source = "./tests/unit/fixtures/mock_provider_sources"
  }
}

run "slot_endpoint_controls_reach_arm_bodies" {
  command = apply

  module {
    source = "./modules/slot"
  }

  variables {
    private_endpoints = {
      configured = {
        name               = "slot-configured"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = "sites-custom"
        lock = {
          kind  = "ReadOnly"
          name  = "slot-lock"
          notes = "Keep this slot endpoint."
        }
        role_assignments = {
          reader = {
            name                       = "22222222-2222-4222-8222-222222222222"
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/33333333-3333-4333-8333-333333333333"
            principal_id               = "44444444-4444-4444-8444-444444444444"
            principal_type             = "ServicePrincipal"
            description                = "Slot endpoint reader"
            condition                  = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals 'example'"
            condition_version          = "2.0"
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
      azapi_resource.private_endpoint["configured"].body.properties.privateLinkServiceConnections[0].properties.groupIds == ["sites-custom"] &&
      azapi_resource.private_endpoint["configured"].body.properties.privateLinkServiceConnections[0].properties.privateLinkServiceId == var.parent_id &&
      alltrue([for ip in azapi_resource.private_endpoint["configured"].body.properties.ipConfigurations : ip.properties.groupId == "sites-custom"]) &&
      azapi_resource.private_endpoint["configured"].body.properties.ipConfigurations[0].properties.memberName == "custom-member" &&
      azapi_resource.private_endpoint["configured"].body.properties.ipConfigurations[1].properties.memberName == "sites-staging"
    )
    error_message = "Slot endpoints must honor explicit subresources and IP members while keeping the site scope and slot member default."
  }
  assert {
    condition = (
      azapi_resource.lock_private_endpoint["configured"].name == "slot-lock" &&
      azapi_resource.lock_private_endpoint["configured"].parent_id == azapi_resource.private_endpoint["configured"].id &&
      azapi_resource.lock_private_endpoint["configured"].body.properties.level == "ReadOnly" &&
      azapi_resource.lock_private_endpoint["configured"].body.properties.notes == "Keep this slot endpoint."
    )
    error_message = "Slot endpoint locks must preserve their scope, name, level and notes."
  }
  assert {
    condition = (
      azapi_resource.role_assignment_private_endpoint["configured-reader"].name == "22222222-2222-4222-8222-222222222222" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].parent_id == azapi_resource.private_endpoint["configured"].id &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.principalId == var.private_endpoints["configured"].role_assignments["reader"].principal_id &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.roleDefinitionId == var.private_endpoints["configured"].role_assignments["reader"].role_definition_id_or_name &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.principalType == "ServicePrincipal" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.description == "Slot endpoint reader" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.condition == var.private_endpoints["configured"].role_assignments["reader"].condition &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].body.properties.conditionVersion == "2.0"
    )
    error_message = "Slot endpoint assignment names must not change role, principal, condition or endpoint scope."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "slot_endpoint_defaults_remain_unchanged" {
  command   = apply
  state_key = "slot-defaults"

  module {
    source = "./modules/slot"
  }

  override_resource {
    target = module.avm_interfaces.random_uuid.role_assignment_name_private_endpoint["configured-reader"]
    values = {
      result = "11111111-1111-4111-8111-111111111111"
    }
  }

  variables {
    private_endpoints = {
      configured = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet"
        subresource_name   = null
        role_assignments = {
          reader = {
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/33333333-3333-4333-8333-333333333333"
            principal_id               = "44444444-4444-4444-8444-444444444444"
          }
        }
        ip_configurations = {
          default_member = {
            name               = "default-ip"
            private_ip_address = "10.0.0.5"
            member_name        = null
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
      endpoint.body.properties.privateLinkServiceConnections[0].properties.groupIds == ["sites-staging"] &&
      endpoint.name == "pep-sites-staging-${uuidv5("url", var.parent_id)}" &&
      endpoint.body.properties.privateLinkServiceConnections[0].name == "pcon-pep-sites-staging-${uuidv5("url", var.parent_id)}" &&
      endpoint.body.properties.customNetworkInterfaceName == "nic-pep-sites-staging-${uuidv5("url", var.parent_id)}"
    ])
    error_message = "Null and omitted slot subresources must retain the sites-staging group and existing generated names."
  }
  assert {
    condition = (
      azapi_resource.private_endpoint["configured"].body.properties.ipConfigurations[0].properties.memberName == "sites-staging" &&
      azapi_resource.role_assignment_private_endpoint["configured-reader"].name == "11111111-1111-4111-8111-111111111111" &&
      length(azapi_resource.lock_private_endpoint) == 0
    )
    error_message = "Slot member and assignment defaults must remain unchanged, without adding endpoint locks."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "slot_endpoint_dns_management_can_remain_external" {
  command = apply

  module {
    source = "./modules/slot"
  }

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
    error_message = "External DNS management must keep the slot endpoint without a managed zone group."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
