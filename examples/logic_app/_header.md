# Logic App (Standard)

This example deploys a Windows Logic App (Standard) in its simplest form.

Logic Apps deployed via this module use `kind = "logicapp"` and run on an App Service Plan, providing the Standard (single-tenant) Logic App experience. The example provisions the required Storage Account and demonstrates the `bundle_version` and `use_extension_bundle` settings.

The example uses `kind = "logicapp"` and `os_type = "Windows"`.
