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

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

/*
module "avm_res_storage_storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.1.1"

  enable_telemetry = false
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.example.name
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
}
*/

/*
resource "azurerm_service_plan" "example" {
  location = azurerm_resource_group.example.location
  # This will equate to Consumption (Serverless) in portal
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Y1"
}
*/

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

resource "azurerm_private_dns_zone" "example" {
  name                = local.azurerm_private_dns_zone_resource_name
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${azurerm_virtual_network.example.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# resource "azurerm_user_assigned_identity" "user" {
#   location            = azurerm_resource_group.example.location
#   name                = module.naming.user_assigned_identity.name_unique
#   resource_group_name = azurerm_resource_group.example.name
# }

module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.10.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-slots"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "functionapp"
  os_type = "Linux"

  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }

  /*
  # Uses an existing app service plan
  os_type = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id
  */

  # Creates a new app service plan
  create_service_plan = true
  new_service_plan = {
    sku_name               = var.sku_for_testing
    zone_balancing_enabled = var.redundancy_for_testing
  }

  /* 
  # Uses an existing storage account
  storage_account_name       = module.avm_res_storage_storageaccount.name
  storage_account_access_key = module.avm_res_storage_storageaccount.resource.primary_access_key
  */

  # Uses the avm-res-storage-storageaccount module to create a new storage account within root module
  function_app_create_storage_account = true
  function_app_storage_account = {
    name                = module.naming.storage_account.name_unique
    resource_group_name = azurerm_resource_group.example.name
    # lock = {
    #   name = "lock-${module.naming.storage_account.name_unique}"
    #   kind = "CanNotDelete"
    # }
  }

  deployment_slots = {
    slot1 = {
      name = "staging"
      site_config = {
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
      # lock = {
      #   kind = "CanNotDelete"
      # }
      # public_network_access_enabled = false 
      private_endpoints = {
        slot_primary = {
          name                          = "slot-primary"
          private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
          subnet_resource_id            = azurerm_subnet.example.id
          tags = {
            environment = "staging"
          }
        }
      }
    }
  }

  # app_service_active_slot = {
  #   slot_key                = "slot1"
  #   overwite_network_config = false
  # }
}
