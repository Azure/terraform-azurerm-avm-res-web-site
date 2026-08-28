// Companion coverage to `tests/unit/private_endpoint_resource_group.tftest.hcl`,
// which pins the same behavior on the site itself.
//
// These runs used to live in the root test file and reach into the slot through
// its `private_endpoints` output. That output was removed as an unused
// whole-resource export, and republishing it just to make an internal scope
// observable is not a reason to widen the module's public contract. Driving the
// submodule directly gets at the same resource attribute and leaves the
// root-to-slot assignment in `main.slots.tf` as the static wiring it is.
//
// The slot is the more interesting half of the fix: here `var.parent_id` is the
// site resource ID rather than a resource group, so every branch below has to
// trim or rebuild it rather than pass it through.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      # The slot's own config submodules validate that their `parent_id` is a
      # `sites/slots` ID, which the mocked provider would otherwise fill with a
      # random string.
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
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

run "slot_private_endpoint_defaults_to_the_app_resource_group" {
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
    error_message = "A slot private endpoint with no `resource_group_name` should land in the app's resource group, trimmed out of the site ID the slot receives as `parent_id`."
  }
}

run "slot_private_endpoint_accepts_a_bare_resource_group_name" {
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
    error_message = "A slot private endpoint should honour a bare `resource_group_name` the same way the parent module does."
  }
}

run "slot_private_endpoint_accepts_a_resource_group_id" {
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
    error_message = "A slot private endpoint should use a `resource_group_name` given as a resource group ID verbatim."
  }

  # Pinned separately from the equality above because this exact string is the
  # regression: reconstructing from an already-qualified ID nests it inside the
  # local subscription's scope.
  assert {
    condition     = azapi_resource.private_endpoint["resource_id"].parent_id != "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups//subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/unit-test-network-rg"
    error_message = "A slot `resource_group_name` given as a resource group ID must not be rebuilt as if it were a bare name, which would nest one scope inside another."
  }
}

run "slot_private_endpoint_rejects_a_resource_id_that_is_not_a_resource_group" {
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
