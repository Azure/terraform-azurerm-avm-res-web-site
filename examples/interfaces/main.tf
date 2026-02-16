module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.11.0"

  is_recommended = true
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

resource "azapi_resource" "resource_group" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"
  body     = {}
}

resource "azapi_resource" "service_plan" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.app_service_plan.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Web/serverfarms@2025-03-01"
  body = {
    kind = "app"
    sku = {
      name = "P1v2"
    }
    properties = {
      reserved      = false
      zoneRedundant = true
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
  type      = "Microsoft.Storage/storageAccounts@2025-01-01"
  body = {
    kind = "StorageV2"
    sku = {
      name = "Standard_ZRS"
    }
    properties = {}
  }
}

resource "azapi_resource" "log_analytics_workspace" {
  location  = azapi_resource.resource_group.location
  name      = "law-test-001"
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.OperationalInsights/workspaces@2025-02-01"
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
  type      = "Microsoft.Network/virtualNetworks@2025-03-01"
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
  type      = "Microsoft.Network/virtualNetworks/subnets@2025-03-01"
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
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
  body      = {}
}

module "avm_res_web_site" {
  source = "../../"

  location                 = azapi_resource.resource_group.location
  name                     = "${module.naming.function_app.name_unique}-interfaces"
  parent_id                = azapi_resource.resource_group.id
  service_plan_resource_id = azapi_resource.service_plan.id
  application_insights = {
    name                  = module.naming.application_insights.name_unique
    parent_id             = azapi_resource.resource_group.id
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
  kind                        = "functionapp"
  managed_identities = {
    # Identities can only be used with the Standard SKU
    system_assigned = true
    user_assigned_resource_ids = [
      azapi_resource.user_assigned_identity.id
    ]
  }
  os_type = "Windows"
  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azapi_resource.private_dns_zone.id]
      subnet_resource_id            = azapi_resource.subnet.id

      tags = {
        webapp = "${module.naming.function_app.name_unique}-interfaces"
      }

    }

  }
  public_network_access_enabled = false
  storage_account_access_key    = data.azapi_resource_action.storage_keys.output.keys[0].value
  storage_account_name          = azapi_resource.storage_account.name
  tags = {
    module  = "Azure/avm-res-web-site/azurerm"
    version = "0.17.2"
  }
}

resource "random_integer" "zone_index" {
  max = length(module.regions.regions_by_name[local.azure_regions[random_integer.region_index.result]].zones)
  min = 1
}

resource "azapi_resource" "network_security_group" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.network_security_group.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/networkSecurityGroups@2025-03-01"
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
  type      = "Microsoft.Network/networkInterfaces@2025-03-01"
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
  type      = "Microsoft.Compute/virtualMachines@2025-04-01"
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
