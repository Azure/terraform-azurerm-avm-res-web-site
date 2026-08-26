# ARM canonicalizes `properties.serverFarmId` to `/providers/Microsoft.Web/serverfarms/`
# (lowercase `serverfarms`), while callers usually supply an ID containing `serverFarms`.
# AzAPI compares the request body against the API response case-sensitively, so the module
# normalizes the provider segment to keep plans empty. See #281.
#
# The normalization is anchored on `/providers/microsoft.web/serverfarms/` rather than the
# bare `serverfarms` segment, so it can only ever rewrite the provider type. The
# `resource_group_named_server_farms` runs are the regression guard for that: an
# unanchored replace also lowercases a resource group or plan named `serverFarms`, which a
# normal ID never exercises.

# Mock every provider in `terraform.tf`, and pin the mocked site ID: under `command =
# apply` a bare mock generates a random string for `azapi_resource.this.id`, which the
# config submodules reject because they validate `parent_id` as a real site resource ID.
mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
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
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverFarms/unit-test-plan"
}

run "site_normalizes_capital_f_server_farms" {
  command = apply

  assert {
    condition     = azapi_resource.this.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
    error_message = "An `azurerm_service_plan`-style ID containing `/serverFarms/` should be normalized to lowercase `/serverfarms/`, got `${azapi_resource.this.body.properties.serverFarmId}`."
  }
}

run "site_leaves_lowercase_server_farms_unchanged" {
  command = apply

  variables {
    service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
  }

  assert {
    condition     = azapi_resource.this.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
    error_message = "An ID that already matches the ARM casing should pass through untouched, got `${azapi_resource.this.body.properties.serverFarmId}`."
  }
}

run "site_preserves_a_resource_group_named_server_farms" {
  command = apply

  variables {
    service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/serverFarms/providers/Microsoft.Web/serverFarms/serverFarms"
  }

  assert {
    condition     = azapi_resource.this.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/serverFarms/providers/Microsoft.Web/serverfarms/serverFarms"
    error_message = "Only the provider type segment may be rewritten. A resource group or plan named `serverFarms` must keep its casing, got `${azapi_resource.this.body.properties.serverFarmId}`."
  }
}

run "slot_normalizes_the_inherited_service_plan_resource_id" {
  command = apply

  # Give the slot a slot-shaped ID; see the note on `mock_provider` above.
  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  variables {
    deployment_slots = {
      staging = {}
    }
  }

  assert {
    condition     = module.slot["staging"].server_farm_resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/unit-test-plan"
    error_message = "A slot inheriting the site's plan ID should get the same normalization, got `${module.slot["staging"].server_farm_resource_id}`."
  }
}

run "slot_normalizes_its_own_server_farm_id_override" {
  command = apply

  # Give the slot a slot-shaped ID; see the note on `mock_provider` above.
  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  variables {
    deployment_slots = {
      staging = {
        server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverFarms/slot-plan"
      }
    }
  }

  assert {
    condition     = module.slot["staging"].server_farm_resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/slot-plan"
    error_message = "A slot's `server_farm_id` override should be normalized too, not just the inherited ID, got `${module.slot["staging"].server_farm_resource_id}`."
  }
}

# The root `service_plan_resource_id` validation requires a literal `Microsoft.Web`, so a
# hand-written lowercase namespace can only reach the normalization through a slot override.
run "slot_normalizes_a_lowercase_provider_namespace" {
  command = apply

  # Give the slot a slot-shaped ID; see the note on `mock_provider` above.
  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  variables {
    deployment_slots = {
      staging = {
        server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/microsoft.web/serverfarms/slot-plan"
      }
    }
  }

  assert {
    condition     = module.slot["staging"].server_farm_resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/serverfarms/slot-plan"
    error_message = "A hand-written `microsoft.web` namespace should be normalized back to `Microsoft.Web`, got `${module.slot["staging"].server_farm_resource_id}`."
  }
}

run "slot_preserves_a_resource_group_named_server_farms" {
  command = apply

  # Give the slot a slot-shaped ID; see the note on `mock_provider` above.
  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  variables {
    deployment_slots = {
      staging = {
        server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/serverFarms/providers/Microsoft.Web/serverFarms/serverFarms"
      }
    }
  }

  assert {
    condition     = module.slot["staging"].server_farm_resource_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/serverFarms/providers/Microsoft.Web/serverfarms/serverFarms"
    error_message = "The slot normalization must also leave a resource group or plan named `serverFarms` alone, got `${module.slot["staging"].server_farm_resource_id}`."
  }
}
