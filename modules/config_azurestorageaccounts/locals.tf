locals {
  storage_mounts = { for k, v in var.storage_shares_to_mount : v.name => {
    type        = v.type
    accountName = v.account_name
    shareName   = v.share_name
    mountPath   = v.mount_path
    accessKey   = v.access_key
  } }
  type = var.is_slot ? "Microsoft.Web/sites/slots/config@2025-03-01" : "Microsoft.Web/sites/config@2025-03-01"
}
