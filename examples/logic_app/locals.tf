locals {
  azure_regions = [
    "eastus",
    "westus"
  ]
  azurerm_private_dns_zone_resource_name = "privatelink.${local.reformatted_subdomain}"
  default_host_name                      = module.avm_res_web_site.resource_uri
  reformatted_subdomain                  = join(".", slice(local.split_subdomain, 1, length(local.split_subdomain)))
  split_subdomain                        = split(".", local.default_host_name)
}
