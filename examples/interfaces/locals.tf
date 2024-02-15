locals {
  azure_regions = [
    "westus2",
    "centralus",
    "eastus2",
    "westeurope",
    "eastasia"
  ]
  azurerm_private_dns_zone_resource_name = "privatelink.${local.reformatted_subdomain}"
  default_hostname                       = module.test.resource_uri
  reformatted_subdomain                  = join(".", slice(local.split_subdomain, 1, length(local.split_subdomain)))
  split_subdomain                        = split(".", local.default_hostname)
}