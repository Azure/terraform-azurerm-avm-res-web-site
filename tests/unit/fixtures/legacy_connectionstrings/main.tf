module "config_connectionstrings" {
  source = "../../../../modules/config_connectionstrings"

  connection_strings = {}
  parent_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
}
