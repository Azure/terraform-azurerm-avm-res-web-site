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
  deployment_slots = {
    staging = {
      managed_identities = {
        system_assigned = true
      }
    }
  }
  managed_identities = {
    system_assigned = true
  }
}

# Sensitivity marks propagate from a module output into whatever consumes it, and
# `terraform validate` cannot see that. These runs are plan/apply-level so the
# marks are actually evaluated.

run "site_identifiers_are_not_sensitive" {
  command = apply

  override_resource {
    target = module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site/slots/staging"
    }
  }

  assert {
    condition     = !issensitive(output.identity_principal_id)
    error_message = "An ordinary downstream output must be able to consume `identity_principal_id` without declaring `sensitive = true`."
  }

  assert {
    condition     = !issensitive(output.resource_id)
    error_message = "An ordinary downstream output must be able to consume `resource_id` without declaring `sensitive = true`."
  }

  assert {
    condition     = !issensitive(output.system_assigned_mi_principal_id)
    error_message = "An ordinary downstream output must be able to consume `system_assigned_mi_principal_id` without declaring `sensitive = true`."
  }

  assert {
    condition     = !issensitive(output.system_assigned_mi_principal_id_slots)
    error_message = "An ordinary downstream output must be able to consume `system_assigned_mi_principal_id_slots` without declaring `sensitive = true`."
  }
}

run "custom_domain_verification_id_is_sensitive" {
  command = apply

  assert {
    condition     = issensitive(output.custom_domain_verification_id)
    error_message = "`custom_domain_verification_id` must stay sensitive to match how the `azurerm` provider marks it on its App Service resources."
  }

  # The escape hatch for consumers who publish the value into a public
  # `asuid.<hostname>` DNS TXT record.
  assert {
    condition     = !issensitive(nonsensitive(output.custom_domain_verification_id))
    error_message = "`nonsensitive()` must be able to unwrap `custom_domain_verification_id` for consumers that publish it in a DNS TXT record."
  }
}
