# Resource Module to no longer support the creation/management of App Service Plan

/*
module "avm_res_web_serverfarm" {
  count = var.create_service_plan ? 1 : 0

  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "0.2.0"

  enable_telemetry = var.enable_telemetry

  location                     = coalesce(var.new_service_plan.location, var.location)
  name                         = coalesce(var.new_service_plan.name, "${var.name}-asp")
  os_type                      = var.os_type
  resource_group_name          = coalesce(var.new_service_plan.resource_group_name, var.resource_group_name)
  sku_name                     = var.kind == "webapp" ? var.new_service_plan.sku_name : coalesce(var.new_service_plan.sku_name, "EP1")
  app_service_environment_id   = var.new_service_plan.app_service_environment_resource_id
  maximum_elastic_worker_count = var.new_service_plan.maximum_elastic_worker_count
  per_site_scaling_enabled     = var.new_service_plan.per_site_scaling_enabled
  tags                         = var.tags
  worker_count                 = var.new_service_plan.worker_count
  zone_balancing_enabled       = var.new_service_plan.zone_balancing_enabled
  lock                         = var.new_service_plan.lock
  role_assignments             = var.new_service_plan.role_assignments
}
*/