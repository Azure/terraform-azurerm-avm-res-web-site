locals {
  # Pinned region list — add more only when intentional.
  # Using a static list with keepers prevents random_integer from
  # regenerating and destroying ALL downstream resources.
  azure_regions = [
    "eastus"
  ]
}
