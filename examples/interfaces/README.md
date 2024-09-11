<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module as a Windows Function App using some of the interfaces.

```hcl
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

# data "azurerm_client_config" "this" {}

# data "azurerm_role_definition" "example" {
#   name = "Contributor"
# }

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique
}

module "avm_res_storage_storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.1.2"

  enable_telemetry = var.enable_telemetry

  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "law-test-001"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
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

resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = var.sku_for_testing
}

module "test" {
  source = "../../"

  # source             = "Azure/avm-res-web-site/azurerm"
  # version = "0.10.1"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-interfaces"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind    = "functionapp"
  os_type = azurerm_service_plan.example.os_type

  service_plan_resource_id = azurerm_service_plan.example.id

  function_app_storage_account_name       = module.avm_res_storage_storageaccount.name
  function_app_storage_account_access_key = module.avm_res_storage_storageaccount.resource.primary_access_key

  public_network_access_enabled = false

  enable_application_insights = true

  application_insights = {
    name                  = module.naming.application_insights.name_unique
    resource_group_name   = azurerm_resource_group.example.name
    location              = azurerm_resource_group.example.location
    application_type      = "web"
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    tags = {
      environment = "dev-tf"
    }
  }

  managed_identities = {
    # Identities can only be used with the Standard SKU    
    system_assigned = true
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.user.id
    ]
  }

  # lock = {
  #   /*
  #   kind = "ReadOnly"
  #   */

  #   /*
  #   kind = "CanNotDelete"
  #   */
  # }

  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
      subnet_resource_id            = azurerm_subnet.example.id

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
      #     role_definition_id_or_name = data.azurerm_role_definition.example.id
      #     principal_id               = data.azurerm_client_config.this.object_id
      #   }
      # }

      tags = {
        webapp = "${module.naming.static_web_app.name_unique}-interfaces"
      }

    }

  }

  # role_assignments = {
  #   role_assignment_1 = {
  #     role_definition_id_or_name = data.azurerm_role_definition.example.id
  #     principal_id               = data.azurerm_client_config.this.object_id
  #   }
  # }

  diagnostic_settings = {
    diagnostic_settings_1 = {
      name                  = "dia_settings_1"
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
    }
  }

  tags = {
    environment = "dev-tf"
  }

}


/*
check "dns" {
  data "azurerm_private_dns_a_record" "assertion" {
    name                = local.split_subdomain[0]
    zone_name           = azurerm_private_dns_zone.example.name
    resource_group_name = azurerm_resource_group.example.name
  }
  assert {
    condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.test.resource_private_endpoints["primary"].private_service_connection).private_ip_address
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

resource "azurerm_network_security_group" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "example" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "AllowAllRDPInbound"
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.example.name
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

# Create the virtual machine
module "avm_res_compute_virtualmachine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.15.1"

  enable_telemetry = var.enable_telemetry

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "${module.naming.virtual_machine.name_unique}-tf"
  sku_size            = module.avm_res_compute_virtualmachine_sku_selector.sku
  os_type             = "Windows"

  zone = random_integer.zone_index.result

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

module "avm_res_compute_virtualmachine_sku_selector" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm//modules/sku_selector"
  version = "0.15.1"

  deployment_region = azurerm_resource_group.example.location
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.6)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.108)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_network_security_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [azurerm_network_security_rule.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) (resource)
- [azurerm_private_dns_zone.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_user_assigned_identity.user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [random_integer.zone_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description:   This variable controls whether or not telemetry is enabled for the module.  
  For more information see <https://aka.ms/avm/telemetryinfo>.  
  If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_sku_for_testing"></a> [sku\_for\_testing](#input\_sku\_for\_testing)

Description: n/a

Type: `string`

Default: `"S1"`

## Outputs

The following outputs are exported:

### <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id)

Description: The principal ID for the identity.

### <a name="output_name"></a> [name](#output\_name)

Description: Name for the resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_uri"></a> [resource\_uri](#output\_resource\_uri)

Description: This is the URI for the resource.

## Modules

The following Modules are called:

### <a name="module_avm_res_compute_virtualmachine"></a> [avm\_res\_compute\_virtualmachine](#module\_avm\_res\_compute\_virtualmachine)

Source: Azure/avm-res-compute-virtualmachine/azurerm

Version: 0.15.1

### <a name="module_avm_res_compute_virtualmachine_sku_selector"></a> [avm\_res\_compute\_virtualmachine\_sku\_selector](#module\_avm\_res\_compute\_virtualmachine\_sku\_selector)

Source: Azure/avm-res-compute-virtualmachine/azurerm//modules/sku_selector

Version: 0.15.1

### <a name="module_avm_res_storage_storageaccount"></a> [avm\_res\_storage\_storageaccount](#module\_avm\_res\_storage\_storageaccount)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: 0.1.2

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.3.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: >= 0.3.0

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->