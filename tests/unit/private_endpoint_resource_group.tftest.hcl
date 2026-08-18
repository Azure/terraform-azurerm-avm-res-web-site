mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      # Under `apply` the mocked provider would otherwise generate a random
      # string here, which the config submodules reject when they validate
      # their `parent_id`. This also gives the slot submodule a well-formed
      # site ID as its `parent_id`, which is what it trims to a resource group.
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry         = false
  location                 = "eastus"
  name                     = "unit-test-site"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
}

run "private_endpoint_defaults_to_the_app_resource_group" {
  command = apply

  variables {
    private_endpoints = {
      default_rg = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoint["default_rg"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
    error_message = "A private endpoint with no `resource_group_name` should land in the app's own resource group, taken straight from `var.parent_id`."
  }
}

run "private_endpoint_accepts_a_bare_resource_group_name" {
  command = apply

  variables {
    private_endpoints = {
      bare_name = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
        resource_group_name = "unit-test-network-rg"
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoint["bare_name"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-network-rg"
    error_message = "A bare `resource_group_name` should be rebuilt into a resource group ID using the subscription from `var.parent_id`. This is the shape reported in #286."
  }
}

run "private_endpoint_accepts_a_resource_group_id" {
  command = apply

  variables {
    private_endpoints = {
      resource_id = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
        resource_group_name = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoint["resource_id"].parent_id == "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
    error_message = "A `resource_group_name` given as a resource group ID should be used verbatim, including a different subscription. This is the shape the AVM private endpoints interface specifies."
  }

  # Pinned separately from the equality above because this exact string is the
  # regression: reconstructing from an already-qualified ID nests it inside the
  # local subscription's scope.
  assert {
    condition     = azapi_resource.private_endpoint["resource_id"].parent_id != "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups//subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
    error_message = "A `resource_group_name` given as a resource group ID must not be rebuilt as if it were a bare name, which would nest one scope inside another."
  }
}

run "private_endpoint_rejects_a_resource_id_that_is_not_a_resource_group" {
  # Deliberately `plan`, not `apply`, unlike every other run in this file.
  # A variable validation failure happens during planning, so the apply can
  # never execute and Terraform marks the whole run failed even though the
  # expected failure occurred. `expect_failures` on a variable requires `plan`.
  command = plan

  variables {
    private_endpoints = {
      not_a_resource_group = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
        resource_group_name = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "slot_private_endpoint_defaults_to_the_app_resource_group" {
  command = apply

  # The shared azapi mock gives every resource the site ID, but the slot's own
  # config submodules validate that their `parent_id` is a `sites/slots` ID.
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
          default_rg = {
            subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
          }
        }
      }
    }
  }

  assert {
    condition     = module.slot["staging"].private_endpoints["default_rg"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
    error_message = "A slot private endpoint with no `resource_group_name` should land in the app's resource group, trimmed out of the site ID the slot receives as `parent_id`."
  }
}

run "slot_private_endpoint_accepts_a_bare_resource_group_name" {
  command = apply

  # The shared azapi mock gives every resource the site ID, but the slot's own
  # config submodules validate that their `parent_id` is a `sites/slots` ID.
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
          bare_name = {
            subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
            resource_group_name = "unit-test-network-rg"
          }
        }
      }
    }
  }

  assert {
    condition     = module.slot["staging"].private_endpoints["bare_name"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-network-rg"
    error_message = "A slot private endpoint should honour a bare `resource_group_name` the same way the parent module does."
  }
}

run "slot_private_endpoint_accepts_a_resource_group_id" {
  command = apply

  # The shared azapi mock gives every resource the site ID, but the slot's own
  # config submodules validate that their `parent_id` is a `sites/slots` ID.
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
          resource_id = {
            subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
            resource_group_name = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
          }
        }
      }
    }
  }

  assert {
    condition     = module.slot["staging"].private_endpoints["resource_id"].parent_id == "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
    error_message = "A slot private endpoint should use a `resource_group_name` given as a resource group ID verbatim."
  }

  # Pinned separately from the equality above because this exact string is the
  # regression: reconstructing from an already-qualified ID nests it inside the
  # local subscription's scope.
  assert {
    condition     = module.slot["staging"].private_endpoints["resource_id"].parent_id != "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups//subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
    error_message = "A slot `resource_group_name` given as a resource group ID must not be rebuilt as if it were a bare name, which would nest one scope inside another."
  }
}
