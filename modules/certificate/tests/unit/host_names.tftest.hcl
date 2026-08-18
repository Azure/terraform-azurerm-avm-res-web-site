// Regression coverage for #284: with `host_names` omitted, every plan proposed
// removing the host names Azure had derived from the certificate's subject
// alternative names.
//
// A note on what these assertions can and cannot reach. `ignore_null_property`
// is applied by the azapi provider when it serialises the request body, and
// `mock_provider` never gets that far — under a mock, `body.properties` still
// carries `hostNames = null`. So there is no way from here to assert "the key
// is absent from the outgoing request"; that is the provider's own behaviour
// and is covered by the provider's tests, not ours.
//
// What we can pin is the part we own, which is where the bug actually lived:
// the attribute that opts us into that behaviour must stay set, and the
// variable must reach the body unchanged whether or not the caller supplies it.

mock_provider "azapi" {}

variables {
  location       = "eastus"
  name           = "test-certificate"
  parent_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
  server_farm_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-plan"
  pfx_blob       = "dGVzdC1wZng="
}

run "host_names_omitted" {
  command = plan

  assert {
    condition     = azapi_resource.this.ignore_null_property == true
    error_message = "`ignore_null_property` must stay enabled. Without it the null `hostNames` is sent to Azure, which returns the derived host names on the next read, and every plan proposes removing them (#284)."
  }

  assert {
    condition     = try(nonsensitive(azapi_resource.this.body.properties.hostNames) == null, false)
    error_message = "With `host_names` omitted the module must leave `hostNames` null and let Azure derive it, rather than substituting a default."
  }
}

run "host_names_explicit" {
  command = plan

  variables {
    host_names = ["app.contoso.com", "www.contoso.com"]
  }

  assert {
    condition     = azapi_resource.this.ignore_null_property == true
    error_message = "`ignore_null_property` must stay enabled regardless of whether `host_names` is supplied."
  }

  // `ignore_null_property` only skips nulls, so a caller-supplied list is still
  // sent and still diffs normally. This is the property that makes it the right
  // fix instead of `ignore_body_changes`, which would mask drift here too.
  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_resource.this.body.properties.hostNames))) == "app.contoso.com,www.contoso.com", false)
    error_message = "An explicit `host_names` list must reach the request body unchanged, so user-managed host names keep being reconciled."
  }
}
