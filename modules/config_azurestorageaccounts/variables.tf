variable "parent_id" {
  type        = string
  description = "The resource ID of the App Service site."
  nullable    = false

  validation {
    error_message = "The value must be a valid Azure App Service site resource ID. e.g. `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/sites/{siteName}`"
    condition     = can(regex("^/subscriptions/[a-f0-9-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Web/sites/[a-zA-Z0-9._-]+$", var.parent_id))
  }
}

variable "storage_shares_to_mount" {
  type = map(object({
    access_key   = string
    account_name = string
    mount_path   = string
    name         = string
    share_name   = string
    type         = optional(string, "AzureFiles")
  }))
  description = <<DESCRIPTION
A map of Storage Account file shares to mount to the App Service.

- `access_key` - (Required) The access key for the Storage Account.
- `account_name` - (Required) The name of the Storage Account.
- `mount_path` - (Required) The path to mount the share at within the App Service.
- `name` - (Required) The name of the storage mount.
- `share_name` - (Required) The name of the file share.
- `type` - (Optional) The type of storage. Defaults to `AzureFiles`.
DESCRIPTION
  nullable    = false
}
