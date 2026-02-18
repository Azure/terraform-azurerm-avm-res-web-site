locals {
  # ARM API uses: "app" (Windows webapp), "app,linux" (Linux webapp),
  # "app,linux,container" (Linux container webapp),
  # "functionapp" (Windows func), "functionapp,linux" (Linux func),
  # "functionapp,linux,container" (Linux container func),
  # "functionapp,linux,container,workflowapp" (Logic App on Linux)
  _is_container = try(var.site_config.application_stack.docker, null) != null
  arm_kind = (
    var.kind == "webapp" ? (var.os_type == "Linux" ? (local._is_container ? "app,linux,container" : "app,linux") : "app") :
    var.kind == "functionapp" ? (var.os_type == "Linux" ? (local._is_container ? "functionapp,linux,container" : "functionapp,linux") : "functionapp") :
    var.kind == "logicapp" ? "functionapp,linux,container,workflowapp" :
    "app"
  )
  is_function_app = var.kind == "functionapp"
  is_linux        = var.os_type == "Linux"
  is_logic_app    = var.kind == "logicapp"
  is_web_app      = var.kind == "webapp"
}
