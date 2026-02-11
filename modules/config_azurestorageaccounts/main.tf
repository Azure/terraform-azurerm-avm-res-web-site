locals {
  storage_mounts = { for k, v in var.storage_shares_to_mount : v.name => {
    type        = v.type
    accountName = v.account_name
    shareName   = v.share_name
    mountPath   = v.mount_path
    accessKey   = v.access_key
  } }
}

resource "azapi_resource" "this" {
  name      = "azurestorageaccounts"
  parent_id = var.parent_id
  type      = "Microsoft.Web/sites/config@2025-03-01"
  body = {
    properties = local.storage_mounts
  }
  response_export_values = []
}
