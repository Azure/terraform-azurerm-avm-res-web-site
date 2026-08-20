locals {
  arm_kind     = try(local.arm_kind_map[var.kind][local.arm_kind_key], "app")
  arm_kind_key = local.is_linux ? (local.is_container ? "linux_container" : "linux") : (local.is_container ? "windows_container" : "windows")
  arm_kind_map = {
    webapp = {
      linux             = "app,linux"
      linux_container   = "app,linux,container"
      windows           = "app"
      windows_container = "app,container,windows"
    }
    functionapp = {
      linux             = "functionapp,linux"
      linux_container   = "functionapp,linux,container"
      windows           = "functionapp"
      windows_container = "functionapp"
    }
    logicapp = {
      linux             = "functionapp,linux,container,workflowapp"
      linux_container   = "functionapp,linux,container,workflowapp"
      windows           = "functionapp,workflowapp"
      windows_container = "functionapp,workflowapp"
    }
  }
  is_container    = try(var.site_config.application_stack.docker, null) != null
  is_function_app = var.kind == "functionapp"
  is_linux        = var.os_type == "Linux"
  is_logic_app    = var.kind == "logicapp"
  is_web_app      = var.kind == "webapp"
  # ARM canonicalizes `properties.serverFarmId` to `/providers/Microsoft.Web/serverfarms/`
  # (lowercase `serverfarms`), but callers commonly supply an ID containing `serverFarms`.
  # AzAPI compares the request body against the API response case-sensitively, so normalize
  # the provider segment here to avoid a perpetual in-place diff on every plan.
  server_farm_id = replace(var.service_plan_resource_id, "/(?i)/providers/microsoft\\.web/serverfarms//", "/providers/Microsoft.Web/serverfarms/")
}
