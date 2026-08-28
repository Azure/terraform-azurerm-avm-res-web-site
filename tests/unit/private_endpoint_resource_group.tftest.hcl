// The slot half of this fix lives in
// `modules/slot/tests/unit/private_endpoint_resource_group.tftest.hcl`, which
// drives that submodule directly. Asserting on it from here would mean reaching
// through a slot output that no longer exists, and republishing one purely to
// make an internal scope observable is not a reason to widen the public
// contract.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      # Under `apply` the mocked provider would otherwise generate a random
      # string here, which the config submodules reject when they validate
      # their `parent_id`.
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

run "private_endpoint_resource_groups_resolve_per_key" {
  command = apply

  # Every other run in this file declares a single private endpoint, which
  # cannot tell a per-key resolution apart from one value shared across the
  # whole map. Three endpoints in one map, each taking a different branch of
  # the local, is the only thing that pins that down.
  variables {
    private_endpoints = {
      bare_name = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
        resource_group_name = "unit-test-network-rg"
      }
      inherits_app_rg = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
      }
      resource_id = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
        resource_group_name = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
      }
    }
  }

  assert {
    condition     = azapi_resource.private_endpoint["bare_name"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-network-rg"
    error_message = "With several private endpoints in one map, a bare `resource_group_name` should still resolve against the subscription from `var.parent_id`."
  }
  assert {
    condition     = azapi_resource.private_endpoint["inherits_app_rg"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg"
    error_message = "An endpoint with no `resource_group_name` must keep the app's resource group even when a sibling endpoint in the same map overrides it."
  }
  assert {
    condition     = azapi_resource.private_endpoint["resource_id"].parent_id == "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
    error_message = "An endpoint given a full resource group ID must keep it, including the other subscription, even when its siblings resolve differently."
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

run "private_endpoint_rejects_an_empty_resource_group_name" {
  # `plan` for the same reason as the run above.
  command = plan

  # An empty string is not a near-miss on the ID shape, so the shape check
  # above passes it through as a bare name and builds
  # `/subscriptions/{sub}/resourceGroups/`, which only fails once ARM sees it.
  variables {
    private_endpoints = {
      empty_resource_group = {
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Network/virtualNetworks/unit-test-vnet/subnets/unit-test-subnet"
        resource_group_name = ""
      }
    }
  }

  expect_failures = [var.private_endpoints]
}
