module "config_backup" {
  source   = "./modules/config_backup"
  for_each = var.backup

  parent_id           = azapi_resource.this.id
  backup_name         = coalesce(each.value.name, "backup-${var.name}")
  enabled             = each.value.enabled
  storage_account_url = each.value.storage_account_url
  schedule = each.value.schedule != null ? {
    for sk, sv in each.value.schedule : sk => sv
  }[keys(each.value.schedule)[0]] : null
}
