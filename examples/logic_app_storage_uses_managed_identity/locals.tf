locals {
  azure_regions = [
    "australiaeast"
  ]
  storage_role_definition_ids = {
    storage_account_contributor    = "17d1049b-9a84-46fb-8f53-869881c3d3ab"
    storage_blob_data_owner        = "b7e6dc6d-f1e8-4753-8033-0f276bb0955b"
    storage_queue_data_contributor = "974c5e8b-45b9-4653-ba55-5f855dd0fb88"
    storage_table_data_contributor = "0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3"
  }
}
