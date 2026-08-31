// Regression coverage for #368: every plan after a successful apply proposed
// rewriting `authsettingsV2`, because the module emitted an explicit `null` for
// nested objects the caller had not supplied. Azure does not persist those
// nulls — a GET returns the sub-object materialised with null members, so
// `{"groups": null, "identities": null}` comes back where the configuration says
// `null`, and the two never reconcile.
//
// The fix the reporter proposed, `ignore_null_property = true`, is not available
// here: the AzAPI provider only offers that argument on `azapi_resource`, not on
// `azapi_update_resource`, in 2.12 (the current release). So the null is kept out
// of `body` in HCL instead, using the same conditional `merge` idiom the rest of
// this file already used for `httpSettings` and `login`.
//
// That makes these assertions stronger than the equivalent ones in
// `modules/certificate/tests/unit/host_names.tftest.hcl`. There, the omission is
// the provider's own serialisation step, which `mock_provider` never reaches, so
// the test can only pin the attribute that opts into it. Here the omission is
// ours and happens while the body is built, so the absence of the key is
// directly observable on the resource.

mock_provider "azapi" {}

variables {
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
}

// The reporter's configuration, reduced to the part that matters: Azure AD is
// configured with a validation block, but neither `allowed_principals` nor
// `jwt_claim_checks` is supplied.
run "unsupplied_nested_objects_are_absent_from_the_body" {
  command = apply

  variables {
    auth_enabled                  = true
    require_authentication        = true
    unauthenticated_client_action = "Return401"

    identity_providers = {
      azure_active_directory = {
        enabled = true
        registration = {
          client_id      = "00000000-0000-0000-0000-000000000000"
          open_id_issuer = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0"
        }
        validation = {
          allowed_audiences = ["api://00000000-0000-0000-0000-000000000000"]
          default_authorization_policy = {
            allowed_applications = ["00000000-0000-0000-0000-000000000000"]
          }
        }
      }
    }
  }

  assert {
    condition     = !can(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedPrincipals)
    error_message = "`allowedPrincipals` must be absent from the body when `allowed_principals` is not supplied. Emitted as null, Azure returns `{groups: null, identities: null}` on the next read and the plan never converges (#368)."
  }

  assert {
    condition     = !can(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.jwtClaimChecks)
    error_message = "`jwtClaimChecks` must be absent from the body when `jwt_claim_checks` is not supplied (#368)."
  }

  assert {
    condition     = !can(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.login)
    error_message = "`login` must be absent from the `azureActiveDirectory` body when no login block is supplied (#368)."
  }

  // Omitting the nulls must not take the supplied configuration with it. These
  // are the siblings of the keys dropped above, at every level of the nesting
  // that changed.
  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedApplications))) == "00000000-0000-0000-0000-000000000000", false)
    error_message = "`allowedApplications` must survive alongside the omitted `allowedPrincipals`."
  }

  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.allowedAudiences))) == "api://00000000-0000-0000-0000-000000000000", false)
    error_message = "`allowedAudiences` must survive alongside the omitted `jwtClaimChecks`."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.registration.clientId) == "00000000-0000-0000-0000-000000000000", false)
    error_message = "A supplied `registration` must still reach the body."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.enabled) == true, false)
    error_message = "Scalar members of an emitted provider object must still reach the body. Only nested objects are omitted; null scalars are left to `ignore_missing_property`, which Azure's response shape already handles."
  }
}

// The complement: when the caller does supply the nested objects, they must be
// sent and keep diffing normally. This is what makes omission the right fix
// rather than `ignore_body_changes`, which would mask drift on these paths even
// when they are managed.
run "supplied_nested_objects_reach_the_body" {
  command = apply

  variables {
    identity_providers = {
      azure_active_directory = {
        enabled = true
        validation = {
          default_authorization_policy = {
            allowed_principals = {
              groups     = ["11111111-1111-1111-1111-111111111111"]
              identities = ["22222222-2222-2222-2222-222222222222"]
            }
          }
          jwt_claim_checks = {
            allowed_groups = ["33333333-3333-3333-3333-333333333333"]
          }
        }
      }
    }
  }

  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedPrincipals.groups))) == "11111111-1111-1111-1111-111111111111", false)
    error_message = "A supplied `allowed_principals.groups` must reach the request body unchanged."
  }

  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedPrincipals.identities))) == "22222222-2222-2222-2222-222222222222", false)
    error_message = "A supplied `allowed_principals.identities` must reach the request body unchanged."
  }

  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.jwtClaimChecks.allowedGroups))) == "33333333-3333-3333-3333-333333333333", false)
    error_message = "A supplied `jwt_claim_checks.allowed_groups` must reach the request body unchanged."
  }
}

// `identityProviders` had the same problem one level higher: it was assigned
// unconditionally from a local that is null when no providers are configured.
run "identity_providers_omitted_entirely" {
  command = apply

  assert {
    condition     = !can(azapi_update_resource.this.body.properties.identityProviders)
    error_message = "`identityProviders` must be absent from the body when no identity providers are configured, for the same reason as its children (#368)."
  }

  // The unconditional half of the body is unaffected.
  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.platform.enabled) == false, false)
    error_message = "Omitting `identityProviders` must not disturb the rest of the body."
  }
}
