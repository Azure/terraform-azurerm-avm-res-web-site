locals {
  name      = "avm422${random_id.name.hex}"
  subnet_id = "${azapi_resource.network.id}/subnets/functions"
}
