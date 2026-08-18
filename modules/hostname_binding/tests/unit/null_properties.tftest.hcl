// Companion coverage to `modules/certificate` for the same bug found while
// auditing #284. `ssl_state` and `thumbprint` are both optional and both
// server-defaulted — Azure returns `sslState: "Disabled"` when you don't set
// it — so sending them as explicit nulls produced the same perpetual diff.
//
// As in the certificate test, `mock_provider` does not run the azapi
// provider's serialisation, so these assertions pin the attribute that opts us
// into the null-stripping plus the variable-to-body wiring, not the provider's
// own behaviour.

mock_provider "azapi" {}

variables {
  hostname  = "app.contoso.com"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/test-site"
}

run "optional_properties_omitted" {
  command = apply

  assert {
    condition     = azapi_resource.this.ignore_null_property == true
    error_message = "`ignore_null_property` must stay enabled. Azure defaults and returns `sslState`, so sending a null for it makes every subsequent plan propose removing the server-side value."
  }

  assert {
    condition     = try(nonsensitive(azapi_resource.this.body.properties.sslState) == null, false)
    error_message = "With `ssl_state` omitted the module must leave `sslState` null rather than picking a default on the caller's behalf."
  }

  assert {
    condition     = try(nonsensitive(azapi_resource.this.body.properties.thumbprint) == null, false)
    error_message = "With `thumbprint` omitted the module must leave `thumbprint` null."
  }
}

run "optional_properties_explicit" {
  command = apply

  variables {
    ssl_state  = "SniEnabled"
    thumbprint = "ABCDEF0123456789ABCDEF0123456789ABCDEF01"
  }

  assert {
    condition     = azapi_resource.this.ignore_null_property == true
    error_message = "`ignore_null_property` must stay enabled regardless of which optional properties are supplied."
  }

  // Only nulls are skipped, so caller-supplied values still reach Azure and
  // still diff normally.
  assert {
    condition     = try(nonsensitive(azapi_resource.this.body.properties.sslState) == "SniEnabled", false)
    error_message = "An explicit `ssl_state` must reach the request body unchanged."
  }

  assert {
    condition     = try(nonsensitive(azapi_resource.this.body.properties.thumbprint) == "ABCDEF0123456789ABCDEF0123456789ABCDEF01", false)
    error_message = "An explicit `thumbprint` must reach the request body unchanged, otherwise the certificate binding silently stops being reconciled."
  }
}
