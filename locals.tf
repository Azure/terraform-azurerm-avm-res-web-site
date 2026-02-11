locals {
  # ARM API uses: "app" (Windows webapp), "app,linux" (Linux webapp),
  # "functionapp" (Windows func), "functionapp,linux" (Linux func),
  # "functionapp,linux,container,workflowapp" (Logic App on Linux)
  arm_kind = (
    var.kind == "webapp" ? (var.os_type == "Linux" ? "app,linux" : "app") :
    var.kind == "functionapp" ? (var.os_type == "Linux" ? "functionapp,linux" : "functionapp") :
    var.kind == "logicapp" ? "functionapp,linux,container,workflowapp" :
    "app"
  )
  is_function_app = var.kind == "functionapp"
  is_linux        = var.os_type == "Linux"
  is_logic_app    = var.kind == "logicapp"
  is_web_app      = var.kind == "webapp"
}

locals {
  subscription_id = data.azapi_client_config.this.subscription_id
}
