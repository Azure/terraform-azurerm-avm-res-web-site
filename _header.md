# Azure Verified Module for App Service (Web Apps, Function Apps, and Logic Apps)

This is an Azure Verified Module (AVM) for deploying and managing Azure App Service resources, including Web Apps, Function Apps, and Logic Apps (Standard).

It supports Linux and Windows operating systems, deployment slots, custom domains, managed identities, private endpoints, diagnostic settings, Application Insights integration, IP restrictions, auto heal, storage mounts, and Flex Consumption plans.

## Migration from earlier module versions

Starting with the `azapi`-based releases of this module, the main site resource
is implemented as a single `azapi_resource.this` regardless of the app kind.
Previous versions of this module used a different `azurerm_*` resource per
flavour (Web App, Function App, Flex Consumption, Logic App Standard, Linux
or Windows). Because Terraform cannot know which of those resource types
existed in your state, this module **does not** ship a built-in `moved` block
for the main site resource - shipping one would silently change the app
`kind` for users of the other flavours (for example turning a Function App
into a Web App) or produce an `Ambiguous move statements` error when combined
with a user-supplied `moved` block.

If you are upgrading from an earlier `azurerm`-based release and want to keep
your existing app in place (instead of having Terraform destroy and recreate
it), add a `moved` block in your **root configuration** that matches the
resource type you previously had in state. Pick the snippet below that
corresponds to your previous app flavour and adapt the module instance
address (for example `module.web_app` or `module.web_app["my_key"]`) to your
configuration.

> Tip: run `terraform state list | grep -i <module-address>` first to confirm
> the exact source address that is currently in state.

### Linux Web App (previously `azurerm_linux_web_app`)

```hcl
moved {
  from = module.web_app.azurerm_linux_web_app.this[0]
  to   = module.web_app.azapi_resource.this
}
```

### Windows Web App (previously `azurerm_windows_web_app`)

```hcl
moved {
  from = module.web_app.azurerm_windows_web_app.this[0]
  to   = module.web_app.azapi_resource.this
}
```

### Linux Function App (previously `azurerm_linux_function_app`)

```hcl
moved {
  from = module.function_app.azurerm_linux_function_app.this[0]
  to   = module.function_app.azapi_resource.this
}
```

### Windows Function App (previously `azurerm_windows_function_app`)

```hcl
moved {
  from = module.function_app.azurerm_windows_function_app.this[0]
  to   = module.function_app.azapi_resource.this
}
```

### Flex Consumption Function App (previously `azurerm_function_app_flex_consumption`)

```hcl
moved {
  from = module.function_app.azurerm_function_app_flex_consumption.this[0]
  to   = module.function_app.azapi_resource.this
}
```

### Logic App Standard (previously `azurerm_logic_app_standard`)

```hcl
moved {
  from = module.logic_app.azurerm_logic_app_standard.this[0]
  to   = module.logic_app.azapi_resource.this
}
```

If the module is instantiated with `for_each` / `count`, include the instance
key or index in the address, for example:

```hcl
moved {
  from = module.web_app["primary"].azurerm_linux_web_app.this[0]
  to   = module.web_app["primary"].azapi_resource.this
}
```

> Important: only add **one** `moved` block per module instance, matching the
> resource type that actually exists in your state. Adding moved blocks for
> resource types that were never in state is harmless (Terraform treats them
> as no-ops), but chaining a `moved` block from one `azurerm_*` flavour to a
> different `azurerm_*` flavour (for example moving a Flex Consumption Function
> App to `azurerm_linux_web_app` first) will cause the body generated for the
> wrong app kind to be applied and can result in failed updates such as
> `InvalidMaximumInstanceCount` from the ARM API.
