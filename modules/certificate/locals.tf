locals {
  # ARM canonicalizes `properties.serverFarmId` to `/providers/Microsoft.Web/serverfarms/`
  # (lowercase `serverfarms`), but callers commonly supply an ID containing `serverFarms`.
  # AzAPI compares the request body against the API response case-sensitively, so normalize
  # the provider segment here to avoid a perpetual in-place diff on every plan.
  server_farm_id = replace(var.server_farm_id, "/(?i)/providers/microsoft\\.web/serverfarms//", "/providers/Microsoft.Web/serverfarms/")
}