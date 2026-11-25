mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/sites/logic-avm-test"
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "random" {}

mock_provider "time" {}

variables {
  enable_telemetry         = false
  kind                     = "logicapp"
  location                 = "eastus"
  name                     = "logic-avm-test"
  os_type                  = "Windows"
  parent_id                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test"
  service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.Web/serverfarms/asp-avm-test"
  storage_account_name     = "stavmtest"
}

run "connection_string_path_is_unchanged" {
  command = apply

  variables {
    storage_account_access_key = "Zm9vYmFyYmF6"
  }

  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage"] == "DefaultEndpointsProtocol=https;AccountName=stavmtest;AccountKey=Zm9vYmFyYmF6"
    error_message = "A Logic App without `storage_uses_managed_identity` must still receive the `AzureWebJobsStorage` connection string."
  }
  assert {
    condition     = length([for key in keys(local.merged_app_settings) : key if startswith(lower(key), "azurewebjobsstorage__")]) == 0
    error_message = "A Logic App without `storage_uses_managed_identity` must not receive identity-based host storage settings."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "single_user_assigned_identity_emits_the_documented_settings" {
  command = apply

  variables {
    storage_uses_managed_identity = true
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test",
      ]
    }
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage")
    error_message = "`AzureWebJobsStorage` must be omitted when the Logic App host storage connection is identity-based."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__managedIdentityResourceId"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test"
    error_message = "The only attached user-assigned identity must be selected for host storage."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__blobServiceUri"] == "https://stavmtest.blob.core.windows.net"
    error_message = "The Blob service URI must be derived from `storage_account_name`."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__queueServiceUri"] == "https://stavmtest.queue.core.windows.net"
    error_message = "The Queue service URI must be derived from `storage_account_name`."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__tableServiceUri"] == "https://stavmtest.table.core.windows.net"
    error_message = "The Table service URI must be derived from `storage_account_name`."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__credential"] == "managedIdentity"
    error_message = "`AzureWebJobsStorage__credential` must be `managedIdentity`."
  }
  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage__accountName") && !contains(keys(local.merged_app_settings), "AzureWebJobsStorage__clientId")
    error_message = "Logic Apps must not receive the Function App identity settings."
  }
  assert {
    condition     = !contains(keys(local.merged_app_settings), "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING")
    error_message = "No content share connection string is expected when `storage_account_share_name` is not set."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "explicit_identity_is_selected_from_several" {
  command = apply

  variables {
    storage_uses_managed_identity     = true
    storage_user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-storage"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-other",
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-storage",
      ]
    }
  }

  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__managedIdentityResourceId"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-storage"
    error_message = "`storage_user_assigned_identity_id` must select the host storage identity."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "caller_supplied_settings_win" {
  command = apply

  variables {
    storage_uses_managed_identity = true
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test",
      ]
    }
    app_settings = {
      azurewebjobsstorage__blobserviceuri  = "https://stavmtest.blob.core.usgovcloudapi.net"
      AzureWebJobsStorage__queueServiceUri = "https://stavmtest.queue.core.usgovcloudapi.net"
      AzureWebJobsStorage__tableServiceUri = "https://stavmtest.table.core.usgovcloudapi.net"
    }
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage__blobServiceUri")
    error_message = "A caller-supplied `azurewebjobsstorage__blobserviceuri` must suppress the module value, because app setting names are case-insensitive."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__queueServiceUri"] == "https://stavmtest.queue.core.usgovcloudapi.net"
    error_message = "A caller-supplied `AzureWebJobsStorage__queueServiceUri` must win over the module value."
  }
  assert {
    condition     = local.merged_app_settings["AzureWebJobsStorage__credential"] == "managedIdentity"
    error_message = "Settings the caller does not supply must keep the module value."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "content_share_keeps_its_connection_string" {
  command = apply

  variables {
    storage_uses_managed_identity = true
    storage_account_access_key    = "Zm9vYmFyYmF6"
    storage_account_share_name    = "logic-avm-test"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test",
      ]
    }
  }

  assert {
    condition     = !contains(keys(local.merged_app_settings), "AzureWebJobsStorage")
    error_message = "`AzureWebJobsStorage` must be omitted when the Logic App host storage connection is identity-based."
  }
  assert {
    condition     = local.merged_app_settings["WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"] == "DefaultEndpointsProtocol=https;AccountName=stavmtest;AccountKey=Zm9vYmFyYmF6"
    error_message = "The content share still needs its connection string."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "runtime_scale_monitoring_is_sent_for_logic_apps" {
  command = apply

  variables {
    storage_account_access_key = "Zm9vYmFyYmF6"
    site_config = {
      runtime_scale_monitoring_enabled = true
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.siteConfig.functionsRuntimeScaleMonitoringEnabled == true
    error_message = "`site_config.runtime_scale_monitoring_enabled` must reach `siteConfig.functionsRuntimeScaleMonitoringEnabled` on a Logic App."
  }
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

# Variable validation runs during plan, so `expect_failures` runs use `command = plan`.

run "identity_path_requires_a_user_assigned_identity" {
  command = plan

  variables {
    storage_uses_managed_identity = true
    managed_identities = {
      system_assigned = true
    }
  }

  expect_failures = [var.managed_identities]
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "identity_path_requires_a_selection_from_several" {
  command = plan

  variables {
    storage_uses_managed_identity = true
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-one",
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-two",
      ]
    }
  }

  expect_failures = [var.managed_identities]
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "selected_identity_must_be_attached" {
  command = plan

  variables {
    storage_uses_managed_identity     = true
    storage_user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-not-attached"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test",
      ]
    }
  }

  expect_failures = [var.managed_identities]
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}

run "content_share_requires_the_access_key" {
  command = plan

  variables {
    storage_uses_managed_identity = true
    storage_account_share_name    = "logic-avm-test"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-avm-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-avm-test",
      ]
    }
  }

  expect_failures = [var.storage_account_access_key]
  providers = {
    azapi  = azapi
    random = random
    time   = time
  }
}
