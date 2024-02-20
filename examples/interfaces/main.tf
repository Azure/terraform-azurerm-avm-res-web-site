terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">=1.9.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
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
  version = ">= 0.3.0"
}

data "azurerm_client_config" "this" {}

data "azurerm_role_definition" "example" {
  name = "Contributor"
}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_storage_account" "example" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name
}

resource "azurerm_service_plan" "example" {
  location = azurerm_resource_group.example.location
  # This will equate to Consumption (Serverless) in portal
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "EP1"
}

resource "azurerm_virtual_network" "example" {
  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.example.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

# resource "azurerm_private_dns_zone" "example" {
#   name                = local.azurerm_private_dns_zone_resource_name
#   resource_group_name = azurerm_resource_group.example.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "example" {
#   name                  = "${azurerm_virtual_network.example.name}-link"
#   private_dns_zone_name = azurerm_private_dns_zone.example.name
#   resource_group_name   = azurerm_resource_group.example.name
#   virtual_network_id    = azurerm_virtual_network.example.id
# }

resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  # source             = "Azure/avm-res-web-site/azurerm"
  # version = 0.1.0

  enable_telemetry = var.enable_telemetry # see variables.tf

  name                = "${module.naming.function_app.name_unique}-default"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  os_type = azurerm_service_plan.example.os_type

  service_plan_resource_id = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  identities = {
    # Identities can only be used with the Standard SKU

    /*
    system = {
      identity_type = "SystemAssigned"
      identity_ids = [ azurerm_user_assigned_identity.system.id ]
    }
    */


    user = {
      identity_type = "UserAssigned"
      identity_ids  = [azurerm_user_assigned_identity.user.id]
    }


    /*
    system_and_user = {
      identity_type = "SystemAssigned, UserAssigned"
      identity_resource_ids = [
        azurerm_user_assigned_identity.user.id
      ]
    }
    */
  }

  lock = {
    kind = "None"

    /*
    kind = "ReadOnly"
    */

    /*
    kind = "CanNotDelete"
    */
  }

  # private_endpoints = {
  #   # Use of private endpoints requires Standard SKU
  #   primary = {
  #     name                          = "primary-interfaces"
  #     private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
  #     subnet_resource_id            = azurerm_subnet.example.id

  #     inherit_lock = true
  #     inherit_tags = true

  #     lock = {
  #       /*
  #       # kind = "None"
  #       */

  #       /*
  #       kind = "ReadOnly"
  #       */

  #       /*
  #       kind = "CanNotDelete"
  #       */
  #     }

  #     role_assignments = {
  #       role_assignment_1 = {
  #         role_definition_id_or_name = data.azurerm_role_definition.example.id
  #         principal_id               = data.azurerm_client_config.this.object_id
  #       }
  #     }

  #     tags = {
  #       webapp = "${module.naming.static_web_app.name_unique}-interfaces"
  #     }

  #   }

  # }

  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name = data.azurerm_role_definition.example.id
      principal_id               = data.azurerm_client_config.this.object_id
    }
  }

  tags = {
    environment = "dev-tf"
  }

}



# check "dns" {
#   data "azurerm_private_dns_a_record" "assertion" {
#     name                = local.split_subdomain[0]
#     zone_name           = azurerm_private_dns_zone.example.name
#     resource_group_name = azurerm_resource_group.example.name
#   }
#   assert {
#     condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.test.resource_private_endpoints["primary"].private_service_connection).private_ip_address
#     error_message = "The private DNS A record for the private endpoint is not correct."
#   }
# }

# VM to test private endpoint connectivity

# module "regions" {
#   source  = "Azure/regions/azurerm"
#   version = ">= 0.4.0"
# }

#seed the test regions 
# locals {
#   test_regions = ["centralus", "eastasia", "westus2", "eastus2", "westeurope", "japaneast"]
# }

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index_vm" {
  max = length(local.azure_regions) - 1
  min = 0
}

resource "random_integer" "zone_index" {
  max = length(module.regions.regions_by_name[local.azure_regions[random_integer.region_index_vm.result]].zones)
  min = 1
}

resource "random_integer" "deploy_sku" {
  max = length(local.deploy_skus) - 1
  min = 0
}

### this segment of code gets valid vm skus for deployment in the current subscription
data "azurerm_subscription" "current" {}

#get the full sku list (azapi doesn't currently have a good way to filter the api call)
data "azapi_resource_list" "example" {
  parent_id              = data.azurerm_subscription.current.id
  type                   = "Microsoft.Compute/skus@2021-07-01"
  response_export_values = ["*"]
}

locals {
  #filter the region virtual machines by desired capabilities (v1/v2 support, 2 cpu, and encryption at host)
  deploy_skus = [
    for sku in local.location_valid_vms : sku
    if length([
      for capability in sku.capabilities : capability
      if(capability.name == "HyperVGenerations" && capability.value == "V1,V2") ||
      (capability.name == "vCPUs" && capability.value == "2") ||
      (capability.name == "EncryptionAtHostSupported" && capability.value == "True") ||
      (capability.name == "CpuArchitectureType" && capability.value == "x64")
    ]) == 4
  ]
  #filter the location output for the current region, virtual machine resources, and filter out entries that don't include the capabilities list
  location_valid_vms = [
    for location in jsondecode(data.azapi_resource_list.example.output).value : location
    if contains(location.locations, local.azure_regions[random_integer.region_index_vm.result]) && # if the sku location field matches the selected location
    length(location.restrictions) < 1 &&                                                           # and there are no restrictions on deploying the sku (i.e. allowed for deployment)
    location.resourceType == "virtualMachines" &&                                                  # and the sku is a virtual machine
    !strcontains(location.name, "C") &&                                                            # no confidential vm skus
    !strcontains(location.name, "B") &&                                                            # no B skus
    length(try(location.capabilities, [])) > 1                                                     # avoid skus where the capabilities list isn't defined
    # try(location.capabilities, []) != []                                                           # avoid skus where the capabilities list isn't defined
  ]
}

#create the virtual machine
module "avm_res_compute_virtualmachine" {
  # source = "../../"
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.4.0"

  resource_group_name     = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  name                    = "${module.naming.virtual_machine.name_unique}-tf"
  virtualmachine_sku_size = local.deploy_skus[random_integer.deploy_sku.result].name

  virtualmachine_os_type = "Windows"
  zone                   = random_integer.zone_index.result

  generate_admin_password_or_ssh_key = false
  admin_username                     = "TestAdmin"
  admin_password                     = "P@ssw0rd1234!"

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  network_interfaces = {
    network_interface_1 = {
      name = "nic-${module.naming.network_interface.name_unique}-tf"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig1-public"
          private_ip_subnet_resource_id = azurerm_subnet.example.id
          create_public_ip_address      = true
          public_ip_address_name        = "pip-${module.naming.virtual_machine.name_unique}-tf"
          is_primary_ipconfiguration    = true
        }
      }
    }
  }

  tags = {

  }

}
