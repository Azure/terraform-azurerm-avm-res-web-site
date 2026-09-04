# Unit tests for the conditionally required variables described in issue #236.
#
# AVM guidance says unit tests should use `command = apply`, since mocked providers
# make apply safe. The two runs that assert on `local.body` do exactly that.
#
# The nine `expect_failures` runs must use `command = plan` instead, and this is not
# an oversight. Variable validation is evaluated during the plan stage, so a failure
# there aborts the apply before it starts. Terraform then reports "Expected failure
# while planning ... the apply operation could not be executed and so the overall
# test case will be marked as a failure" and fails the run despite the failure being
# the point of the test. That applies to any `expect_failures` on a variable, so
# `plan` is the only command these can use.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Web/sites/app-unit-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  location                 = "eastus"
  name                     = "app-unit-test"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Web/serverfarms/asp-test"
  enable_telemetry         = false
}

run "flex_consumption_requires_runtime_name" {
  command = plan

  variables {
    kind                        = "functionapp"
    os_type                     = "Linux"
    function_app_uses_fc1       = true
    fc1_runtime_version         = "20"
    storage_authentication_type = "SystemAssignedIdentity"
    storage_container_endpoint  = "https://sttest.blob.core.windows.net/deployments"
  }

  expect_failures = [var.fc1_runtime_name]
}

run "flex_consumption_requires_runtime_version" {
  command = plan

  variables {
    kind                        = "functionapp"
    os_type                     = "Linux"
    function_app_uses_fc1       = true
    fc1_runtime_name            = "node"
    storage_authentication_type = "SystemAssignedIdentity"
    storage_container_endpoint  = "https://sttest.blob.core.windows.net/deployments"
  }

  expect_failures = [var.fc1_runtime_version]
}

run "flex_consumption_requires_storage_authentication_type" {
  command = plan

  variables {
    kind                       = "functionapp"
    os_type                    = "Linux"
    function_app_uses_fc1      = true
    fc1_runtime_name           = "node"
    fc1_runtime_version        = "20"
    storage_container_endpoint = "https://sttest.blob.core.windows.net/deployments"
  }

  expect_failures = [var.storage_authentication_type]
}

run "flex_consumption_requires_storage_container_endpoint" {
  command = plan

  variables {
    kind                        = "functionapp"
    os_type                     = "Linux"
    function_app_uses_fc1       = true
    fc1_runtime_name            = "node"
    fc1_runtime_version         = "20"
    storage_authentication_type = "SystemAssignedIdentity"
  }

  expect_failures = [var.storage_container_endpoint]
}

run "user_assigned_identity_authentication_requires_identity_id" {
  command = plan

  variables {
    kind                        = "functionapp"
    os_type                     = "Linux"
    function_app_uses_fc1       = true
    fc1_runtime_name            = "node"
    fc1_runtime_version         = "20"
    storage_authentication_type = "UserAssignedIdentity"
    storage_container_endpoint  = "https://sttest.blob.core.windows.net/deployments"
  }

  expect_failures = [var.storage_user_assigned_identity_id]
}

run "logic_app_requires_storage_account_name" {
  command = plan

  variables {
    kind                       = "logicapp"
    os_type                    = "Windows"
    storage_account_access_key = "not-a-real-key"
  }

  expect_failures = [var.storage_account_name]
}

run "logic_app_requires_storage_account_access_key" {
  command = plan

  variables {
    kind                 = "logicapp"
    os_type              = "Windows"
    storage_account_name = "sttest"
  }

  expect_failures = [var.storage_account_access_key]
}

run "managed_identity_storage_requires_storage_account_name" {
  command = plan

  variables {
    kind                          = "functionapp"
    os_type                       = "Linux"
    storage_uses_managed_identity = true
    # An identity is separately required, and would otherwise fail its own
    # validation and be reported as an unexpected failure alongside this one.
    managed_identities = {
      system_assigned = true
    }
  }

  expect_failures = [var.storage_account_name]
}

run "unsupported_storage_container_type_is_rejected" {
  command = plan

  variables {
    kind                   = "functionapp"
    os_type                = "Linux"
    function_app_uses_fc1  = false
    storage_container_type = "fileShare"
  }

  expect_failures = [var.storage_container_type]
}

run "flex_consumption_defaults_storage_container_type" {
  command = apply

  variables {
    kind                              = "functionapp"
    os_type                           = "Linux"
    function_app_uses_fc1             = true
    fc1_runtime_name                  = "node"
    fc1_runtime_version               = "20"
    storage_authentication_type       = "UserAssignedIdentity"
    storage_container_endpoint        = "https://sttest.blob.core.windows.net/deployments"
    storage_user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uai-test"
  }

  assert {
    condition     = local.body.properties.functionAppConfig.deployment.storage.type == "blobcontainer"
    error_message = "storage_container_type should default to blobContainer for Flex Consumption Function Apps."
  }
}

run "web_app_ignores_flex_consumption_variables" {
  command = apply

  assert {
    condition     = local.body.properties.functionAppConfig == null
    error_message = "functionAppConfig should stay null when function_app_uses_fc1 is false."
  }
}
