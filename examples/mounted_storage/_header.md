# Azure Storage Mount

This example deploys an App Service with Azure Storage file shares mounted to the application using the `storage_shares_to_mount` variable.

Storage mounts allow your App Service to access Azure Files shares as local directories, useful for sharing data between instances or persisting files outside the app's own file system. The example configures mounts on both the main app and a deployment slot.

The example uses `kind = "webapp"` with the `storage_shares_to_mount` configuration.
