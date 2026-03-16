locals {
  _arm_kind_key = local.is_linux ? (local.is_container ? "linux_container" : "linux") : (local.is_container ? "windows_container" : "windows")
  _arm_kind_map = {
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
  arm_kind        = try(local._arm_kind_map[var.kind][local._arm_kind_key], "app")
  is_container    = try(var.site_config.application_stack.docker, null) != null
  is_function_app = var.kind == "functionapp"
  is_linux        = var.os_type == "Linux"
  is_logic_app    = var.kind == "logicapp"
  is_web_app      = var.kind == "webapp"
}
