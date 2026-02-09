## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.8.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group


# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# data "azapi_client_config" "this" {}

# Contributor role definition ID: b24988ac-6180-42a0-ab88-20f7382dd24c
# data "azurerm_role_definition" "example" {
#   name = "Contributor"
# }

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body     = {}
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2024-04-01"
  body = {
    kind = "app"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved = false
    }
  }
  tags = {
    app = "${module.naming.function_app.name_unique}-interfaces"
  }
}

resource "azapi_resource" "storage_account" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.storage_account.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Storage/storageAccounts@2023-05-01"
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_ZRS"
    }
    properties = {}
  }
}

data "azapi_resource_action" "storage_keys" {
  action                 = "listKeys"
  method                 = "POST"
  resource_id            = azapi_resource.storage_account.id
  type                   = "Microsoft.Storage/storageAccounts@2023-05-01"
  response_export_values = ["keys"]
}

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "law-test-001"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2023-09-01"
  body = {
    properties = {
      retentionInDays = 30
      sku = {
        name = "PerGB2018"
      }
    }
  }
}

resource "azapi_resource" "virtual_network" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.virtual_network.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["192.168.0.0/24"]
      }
    }
  }
}

resource "azapi_resource" "subnet" {
  name      = module.naming.subnet.name_unique
  parent_id = azapi_resource.virtual_network.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  body = {
    properties = {
      addressPrefix = "192.168.0.0/24"
    }
  }
}

resource "azapi_resource" "private_dns_zone" {
  location  = "global"
  name      = local.azurerm_private_dns_zone_resource_name
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/privateDnsZones@2024-06-01"
  body      = {}
}

resource "azapi_resource" "private_dns_zone_virtual_network_link" {
  location  = "global"
  name      = "${azapi_resource.virtual_network.name}-link"
  parent_id = azapi_resource.private_dns_zone.id
  type      = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01"
  body = {
    properties = {
      virtualNetwork = {
        id = azapi_resource.virtual_network.id
      }
      registrationEnabled = false
    }
  }
}

resource "azapi_resource" "user_assigned_identity" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.user_assigned_identity.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31"
  body      = {}
}

module "avm_res_web_site" {
  source = "../../"

  kind     = "functionapp"
  location = azapi_resource.resource_group.location
  name     = "${module.naming.function_app.name_unique}-interfaces"
  # Uses an existing app service plan
  os_type                  = "Windows"
  resource_group_name      = azapi_resource.resource_group.name
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    name                  = module.naming.application_insights.name_unique
    resource_group_name   = azapi_resource.resource_group.name
    location              = azapi_resource.resource_group.location
    application_type      = "web"
    workspace_resource_id = azapi_resource.log_analytics_workspace.id
    tags = {
      environment = "dev-tf"
    }
  }
  diagnostic_settings = {
    diagnostic_settings_1 = {
      name                  = "dia_settings_1"
      workspace_resource_id = azapi_resource.log_analytics_workspace.id
    }
  }
  enable_application_insights = true
  enable_telemetry            = var.enable_telemetry
  managed_identities = {
    # Identities can only be used with the Standard SKU
    system_assigned = true
    user_assigned_resource_ids = [
      azapi_resource.user_assigned_identity.id
    ]
  }
  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azapi_resource.private_dns_zone.id]
      subnet_resource_id            = azapi_resource.subnet.id

      # lock = {
      #   /*
      #   kind = "ReadOnly"
      #   */

      #   /*
      #   kind = "CanNotDelete"
      #   */
      # }

      # role_assignments = {
      #   role_assignment_1 = {
      #     role_definition_id_or_name = "/subscriptions/${data.azapi_client_config.this.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      #     principal_id               = data.azapi_client_config.this.object_id
      #   }
      # }

      tags = {
        webapp = "${module.naming.function_app.name_unique}-interfaces"
      }

    }

  }
  public_network_access_enabled = false
  storage_account_access_key    = data.azapi_resource_action.storage_keys.output.keys[0].value
  # Uses an existing storage account
  storage_account_name = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}


/*
check "dns" {
  data "azurerm_private_dns_a_record" "assertion" {
    name                = local.split_subdomain[0]
    zone_name           = azapi_resource.private_dns_zone.name
    resource_group_name = azapi_resource.resource_group.name
  }
  assert {
    condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.avm_res_web_site.resource_private_endpoints["primary"].private_service_connection).private_ip_address
    error_message = "The private DNS A record for the private endpoint is not correct."
  }
}
*/

# VM to test private endpoint connectivity

# This allows us to randomize the region for the resource group.
# resource "random_integer" "region_index_vm" {
#   max = length(local.azure_regions) - 1
#   min = 0
# }

resource "random_integer" "zone_index" {
  max = length(module.regions.regions_by_name[local.azure_regions[random_integer.region_index.result]].zones)
  min = 1
}

resource "azapi_resource" "network_security_group" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.network_security_group.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/networkSecurityGroups@2024-05-01"
  body = {
    properties = {
      securityRules = [
        {
          name = "AllowAllRDPInbound"
          properties = {
            access                   = "Allow"
            direction                = "Inbound"
            protocol                 = "Tcp"
            priority                 = 100
            destinationAddressPrefix = "*"
            destinationPortRange     = "3389"
            sourceAddressPrefix      = "*"
            sourcePortRange          = "*"
          }
        }
      ]
    }
  }
}

resource "azapi_resource" "network_interface" {
  location  = azapi_resource.resource_group.location
  name      = "example-nic"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/networkInterfaces@2024-05-01"
  body = {
    properties = {
      ipConfigurations = [
        {
          name = "internal"
          properties = {
            privateIPAllocationMethod = "Dynamic"
            subnet = {
              id = azapi_resource.subnet.id
            }
          }
        }
      ]
    }
  }
}

resource "azapi_resource" "windows_virtual_machine" {
  location  = azapi_resource.resource_group.location
  name      = "example-machine"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Compute/virtualMachines@2024-07-01"
  body = {
    properties = {
      hardwareProfile = {
        vmSize = "Standard_D2s_v5"
      }
      osProfile = {
        computerName  = "example-machine"
        adminUsername = "adminuser"
        adminPassword = "P@$$w0rd1234!"
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.network_interface.id
          }
        ]
      }
      storageProfile = {
        osDisk = {
          createOption = "FromImage"
          caching      = "ReadWrite"
          managedDisk = {
            storageAccountType = "Premium_LRS"
          }
        }
        imageReference = {
          publisher = "MicrosoftWindowsServer"
          offer     = "WindowsServer"
          sku       = "2016-Datacenter"
          version   = "latest"
        }
      }
    }
  }
}

# Create the virtual machine
# module "avm_res_compute_virtualmachine" {
#   source  = "Azure/avm-res-compute-virtualmachine/azurerm"
#   version = "0.16.4"

#   enable_telemetry = var.enable_telemetry

#   resource_group_name = azapi_resource.resource_group.name
#   location            = azapi_resource.resource_group.location
#   name                = "${module.naming.virtual_machine.name_unique}-tf"
#   sku_size            = module.avm_res_compute_virtualmachine_sku_selector.sku
#   os_type             = "Windows"

#   zone = random_integer.zone_index.result

#   generate_admin_password_or_ssh_key = false
#   admin_username                     = "TestAdmin"
#   admin_password                     = "P@ssw0rd1234!"

#   source_image_reference = {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }

#   network_interfaces = {
#     network_interface_1 = {
#       name = "nic-${module.naming.network_interface.name_unique}-tf"
#       ip_configurations = {
#         ip_configuration_1 = {
#           name                          = "${module.naming.network_interface.name_unique}-ipconfig1-public"
#           private_ip_subnet_resource_id = azapi_resource.subnet.id
#           create_public_ip_address      = true
#           public_ip_address_name        = "pip-${module.naming.virtual_machine.name_unique}-tf"
#           is_primary_ipconfiguration    = true
#         }
#       }
#     }
#   }

#   tags = {

#   }

# }

# module "avm_res_compute_virtualmachine_sku_selector" {
#   source  = "Azure/avm-res-compute-virtualmachine/azurerm//modules/sku_selector"
#   version = "0.16.4"

#   deployment_region = azapi_resource.resource_group.location
# }
