# Unit tests for the identity-based `AzureWebJobsStorage` connection, issue #367.
#
# `AzureWebJobsStorage__accountName` on its own tells the Functions host which
# storage account to use but not how to authenticate to it, so the host falls
# back to looking for a connection string and fails at startup. On Flex
# Consumption with `shared_access_key_enabled = false` there is no fallback at
# all. The deployment still succeeds, which is why this needs a plan-time
# regression test rather than an example: a green apply proves nothing.
#
# These assertions read `local.merged_app_settings` directly, the same way
# `conditionally_required_variables.tftest.hcl` reads `local.body`, so no public
# submodule output has to exist just to make the behavior observable.

mock_provider "azapi" {
  # Downstream submodules validate that parent_id looks like a real site
  # resource ID, so the default random mock ID has to be overridden.
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/func-avm-test"
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  location                 = "eastus"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/serverfarms/asp-avm-test"
  enable_telemetry         = false
  kind                     = "functionapp"
  os_type                  = "Linux"
  name                     = "func-avm-test"
  storage_account_name     = "stavmtest"
}

run "system_assigned_identity_emits_account_name_and_credential" {
  command = apply

  variables {
    storage_uses_managed_identity = true
    managed_identities = {
      system_assigned = true
    }
  }

  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__accountName"] == "stavmtest"
    error_message = "An identity-based host storage connection must name the storage account."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__credential"] == "managedidentity"
    error_message = "Without `AzureWebJobsStorage__credential = managedidentity` the Functions host does not use a managed identity and fails to authenticate to storage at startup."
  }
  # `__clientId` selects a *user-assigned* identity. Setting it for a
  # system-assigned identity is not applicable, and the docs warn it is invalid
  # to specify an identity selector that does not apply.
  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage__clientId")
    error_message = "`AzureWebJobsStorage__clientId` must not be set for a system-assigned identity."
  }
  # The identity-based connection replaces the connection string rather than
  # sitting beside it.
  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage")
    error_message = "`AzureWebJobsStorage` must be omitted entirely when the host storage connection is identity-based."
  }
}

run "user_assigned_identity_emits_client_id" {
  command = apply

  variables {
    storage_uses_managed_identity            = true
    storage_user_assigned_identity_client_id = "11111111-2222-3333-4444-555555555555"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test",
      ]
    }
  }

  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__clientId"] == "11111111-2222-3333-4444-555555555555"
    error_message = "A user-assigned identity must be selected with `AzureWebJobsStorage__clientId`, otherwise the host authenticates as the system-assigned identity."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__credential"] == "managedidentity"
    error_message = "`AzureWebJobsStorage__clientId` requires `AzureWebJobsStorage__credential = managedidentity`."
  }
}

# Module defaults are merged *after* `var.app_settings`, so without an explicit
# guard a caller cannot correct any of these values. This is the same
# case-insensitive override introduced for WEBSITE_NODE_DEFAULT_VERSION in #344.
# polymind-inc/terraform-azurerm-acmebot supplies exactly these keys today.
run "caller_supplied_settings_win" {
  command = apply

  variables {
    storage_uses_managed_identity            = true
    storage_user_assigned_identity_client_id = "11111111-2222-3333-4444-555555555555"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test",
      ]
    }
    app_settings = {
      azurewebjobsstorage__credential  = "workloadidentity"
      AzureWebJobsStorage__clientId    = "99999999-8888-7777-6666-555555555555"
      AzureWebJobsStorage__accountName = "stcallerchoice"
    }
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage__credential")
    error_message = "A caller-supplied `azurewebjobsstorage__credential` must suppress the module default, matching Azure's case-insensitive app setting names."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__clientId"] == "99999999-8888-7777-6666-555555555555"
    error_message = "A caller-supplied `AzureWebJobsStorage__clientId` must win over the module default."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__accountName"] == "stcallerchoice"
    error_message = "A caller-supplied `AzureWebJobsStorage__accountName` must win over the module default."
  }
}

run "connection_string_path_is_unchanged" {
  command = apply

  variables {
    storage_uses_managed_identity = false
    storage_account_access_key    = "Zm9vYmFyYmF6"
  }

  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage"] == "DefaultEndpointsProtocol=https;AccountName=stavmtest;AccountKey=Zm9vYmFyYmF6"
    error_message = "Connection-string function apps must still receive `AzureWebJobsStorage`."
  }
  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage__credential")
    error_message = "Connection-string function apps must not receive identity-based connection settings."
  }
  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage__accountName")
    error_message = "Connection-string function apps must not receive identity-based connection settings."
  }
}

# The two runs below use `command = plan` rather than `apply`, for the reason
# `conditionally_required_variables.tftest.hcl` records: variable validation is
# evaluated during plan, so a failure there aborts the apply and Terraform marks
# the whole run failed even though the failure is the point of the test. #349
# established that `plan` is the only command an `expect_failures` on a variable
# can use.
#
# `storage_uses_managed_identity = true` asks the Functions host to authenticate
# with a managed identity. It does not give it one. `managed_identities` defaults
# to no identity at all, so both of these configurations plan cleanly without the
# validation and then fail at startup exactly the way #367 describes.

run "managed_identity_storage_requires_an_identity" {
  command = plan

  variables {
    storage_uses_managed_identity = true
  }

  expect_failures = [var.managed_identities]
}

run "client_id_requires_an_attached_user_assigned_identity" {
  command = plan

  variables {
    storage_uses_managed_identity            = true
    storage_user_assigned_identity_client_id = "11111111-2222-3333-4444-555555555555"
  }

  expect_failures = [var.managed_identities]
}
