// ARM canonicalizes `properties.serverFarmId` to `/providers/Microsoft.Web/serverfarms/`
// (lowercase `serverfarms`), while callers usually supply an ID containing `serverFarms` —
// that is what `azurerm_service_plan` hands back. AzAPI compares the request body against
// the API response case-sensitively, so this submodule normalizes the provider segment for
// the same reason the site and slot bodies do. See #281 and #348.
//
// The submodule is the right place for it: the root passes `var.service_plan_resource_id`
// through to `module.certificate` unnormalized, and the submodule is documented as
// directly consumable, so a caller reaching it without the root gets the fix too.
//
// The normalization is anchored on `/providers/microsoft.web/serverfarms/` rather than the
// bare `serverfarms` segment, so it can only ever rewrite the provider type. The
// `resource_group_and_plan_named_server_farms` run is the regression guard for that: an
// unanchored replace also lowercases a resource group or plan named `serverFarms`, which a
// normal ID never exercises.

mock_provider "azapi" {}

variables {
  location  = "eastus"
  name      = "test-certificate"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
  pfx_blob  = "dGVzdC1wZng="
}

run "normalizes_capital_f_server_farms" {
  command = apply

  variables {
    server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverFarms/test-plan"
  }

  assert {
    condition     = azapi_resource.this.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-plan"
    error_message = "An `azurerm_service_plan`-style ID containing `/serverFarms/` should be normalized to lowercase `/serverfarms/`, got `${azapi_resource.this.body.properties.serverFarmId}`."
  }
}

run "leaves_lowercase_server_farms_unchanged" {
  command = apply

  variables {
    server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-plan"
  }

  assert {
    condition     = azapi_resource.this.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-plan"
    error_message = "An ID that already matches the ARM casing should pass through untouched, got `${azapi_resource.this.body.properties.serverFarmId}`."
  }
}

// Unlike the root's `service_plan_resource_id`, this variable has no validation pinning a
// literal `Microsoft.Web`, so a hand-written lowercase namespace reaches the body directly.
run "normalizes_a_lowercase_provider_namespace" {
  command = apply

  variables {
    server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/microsoft.web/serverfarms/test-plan"
  }

  assert {
    condition     = azapi_resource.this.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-plan"
    error_message = "A hand-written `microsoft.web` namespace should be normalized back to `Microsoft.Web`, got `${azapi_resource.this.body.properties.serverFarmId}`."
  }
}

run "resource_group_and_plan_named_server_farms" {
  command = apply

  variables {
    server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/serverFarms/providers/Microsoft.Web/serverFarms/serverFarms"
  }

  assert {
    condition     = azapi_resource.this.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/serverFarms/providers/Microsoft.Web/serverfarms/serverFarms"
    error_message = "Only the provider type segment may be rewritten. A resource group or plan named `serverFarms` must keep its casing, got `${azapi_resource.this.body.properties.serverFarmId}`."
  }
}
