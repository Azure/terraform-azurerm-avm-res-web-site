// Regression coverage for #368 and #378 together, which pull in opposite
// directions.
//
// #368: every plan after a successful apply proposed rewriting `authsettingsV2`.
// A GET returns `allowedPrincipals` and `jwtClaimChecks` materialised with null
// members — `{"groups": null, "identities": null}` — where the configuration
// said `null`, and the two never reconciled. `ignore_null_property`, the fix the
// reporter proposed, is not available: AzAPI 2.12 offers it on `azapi_resource`
// only, not on `azapi_update_resource`.
//
// #377 fixed that by moving roughly seventeen nested objects out of the body
// into conditional `merge` arms, so an unsupplied object contributes no key at
// all. Only two of them had a confirmed drift report. The other fifteen were
// converted on consistency grounds, and that broke clearing:
// `azapi_update_resource` merges the configured body over what Azure already
// holds, so a key absent from `body` keeps its previous value. Omission stops
// managing a property; it does not clear it (#378).
//
// So the two shapes below are deliberate, and the split is evidence-driven:
//
//   - `allowedPrincipals` and `jwtClaimChecks` carry Azure's materialised shape,
//     the object with null members. That matches the response, so the plan
//     converges, and it names every member the 2025-03-01 schema declares for
//     them, so it is still a clearing value.
//   - Every other unsupplied nested object is an explicit `null`, which is what
//     the module sent before #377 and what gives a caller any way to take a
//     property back off.
//
// What none of this can prove is the transition itself. The merge happens inside
// the provider against a live GET, so mocked assertions on the rendered body
// never reach it — which is how #377 shipped green with this defect in it.

mock_provider "azapi" {}

variables {
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/unit-test-rg/providers/Microsoft.Web/sites/unit-test-site"
}

// The reporter's configuration, reduced to the part that matters: Azure AD is
// configured with a validation block, but neither `allowed_principals` nor
// `jwt_claim_checks` is supplied.
run "the_two_drifting_objects_carry_azures_cleared_shape" {
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
    condition     = can(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedPrincipals)
    error_message = "`allowedPrincipals` must be present in the body as Azure's cleared shape, not omitted, so removing it clears it rather than leaving the previous value live (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedPrincipals.groups, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedPrincipals.identities, "omitted") == null
    error_message = "The cleared `allowedPrincipals` must carry null members, matching what Azure returns on read, so the plan converges (#368)."
  }

  assert {
    condition     = can(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.jwtClaimChecks)
    error_message = "`jwtClaimChecks` must be present in the body as Azure's cleared shape, not omitted (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.jwtClaimChecks.allowedClientApplications, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.jwtClaimChecks.allowedGroups, "omitted") == null
    error_message = "The cleared `jwtClaimChecks` must carry null members, matching what Azure returns on read (#368)."
  }

  // Neither cleared shape may take the supplied configuration with it. These are
  // the siblings of the two objects above, at every level of the nesting.
  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedApplications))) == "00000000-0000-0000-0000-000000000000", false)
    error_message = "`allowedApplications` must survive alongside the cleared `allowedPrincipals`."
  }

  assert {
    condition     = try(join(",", tolist(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.allowedAudiences))) == "api://00000000-0000-0000-0000-000000000000", false)
    error_message = "`allowedAudiences` must survive alongside the cleared `jwtClaimChecks`."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.registration.clientId) == "00000000-0000-0000-0000-000000000000", false)
    error_message = "A supplied `registration` must still reach the body."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.enabled) == true, false)
    error_message = "Scalar members of an emitted provider object must still reach the body."
  }

  // `login` sits directly under `azureActiveDirectory` and was already a merge
  // arm before #377, so it stays one. This pins that the idiom that predates
  // #377 was left alone.
  assert {
    condition     = !can(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.login)
    error_message = "`azureActiveDirectory.login` used a conditional merge arm before #377 and must keep doing so."
  }
}

// The complement: when the caller does supply the two objects, they must be sent
// and keep diffing normally. This is what makes the cleared shape the right fix
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

// Every nested object #377 converted that has no confirmed drift report is back
// to an explicit `null`. One provider per family, covering each distinct nested
// object the conversion touched, so a future mechanical rewrite cannot silently
// drop one back into a merge arm.
run "unsupplied_nested_objects_are_explicit_nulls" {
  command = apply

  variables {
    identity_providers = {
      apple                 = { enabled = true }
      azure_static_web_apps = { enabled = true }
      facebook              = { enabled = true }
      github                = { enabled = true }
      google                = { enabled = true }
      twitter               = { enabled = true }

      legacy_microsoft_account = { enabled = true }

      azure_active_directory = {
        enabled = true
        validation = {
          allowed_audiences = ["api://00000000-0000-0000-0000-000000000000"]
        }
      }

      custom_open_id_connect_providers = {
        contoso = { enabled = true }
      }
    }
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.apple.login, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.apple.registration, "omitted") == null
    error_message = "Apple's `login` and `registration` must be explicit nulls, so removing them clears them rather than leaving the previous values live (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.registration, "omitted") == null
    error_message = "`azureActiveDirectory.registration` must be an explicit null (#378)."
  }

  // `defaultAuthorizationPolicy` is the object whose null-vs-cleared-shape
  // treatment is least settled: it sits at the same depth as `jwtClaimChecks`,
  // which #368 did observe materialising. No report has shown Azure
  // materialising this one, so it stays a null rather than being generalised to
  // — which is the exact mistake #377 made.
  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy, "omitted") == null
    error_message = "`defaultAuthorizationPolicy` must be an explicit null while no drift report covers it (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.azureStaticWebApps.registration, "omitted") == null
    error_message = "`azureStaticWebApps.registration` must be an explicit null (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.customOpenIdConnectProviders["contoso"].login, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.customOpenIdConnectProviders["contoso"].registration, "omitted") == null
    error_message = "A custom OIDC provider's `login` and `registration` must be explicit nulls (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.facebook.login, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.facebook.registration, "omitted") == null
    error_message = "Facebook's `login` and `registration` must be explicit nulls (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.gitHub.login, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.gitHub.registration, "omitted") == null
    error_message = "GitHub's `login` and `registration` must be explicit nulls (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.google.login, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.google.registration, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.google.validation, "omitted") == null
    error_message = "Google's `login`, `registration` and `validation` must be explicit nulls (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.legacyMicrosoftAccount.login, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.legacyMicrosoftAccount.registration, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.legacyMicrosoftAccount.validation, "omitted") == null
    error_message = "Legacy Microsoft Account's `login`, `registration` and `validation` must be explicit nulls (#378)."
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.twitter.registration, "omitted") == null
    error_message = "Twitter's `registration` must be an explicit null (#378)."
  }
}

// The nested objects a custom OIDC `registration` owns are one level deeper than
// anything above, and #377 converted them too.
run "custom_oidc_registration_children_are_explicit_nulls" {
  command = apply

  variables {
    identity_providers = {
      custom_open_id_connect_providers = {
        contoso = {
          enabled = true
          registration = {
            client_id = "00000000-0000-0000-0000-000000000000"
          }
        }
      }
    }
  }

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders.customOpenIdConnectProviders["contoso"].registration.clientCredential, "omitted") == null && try(azapi_update_resource.this.body.properties.identityProviders.customOpenIdConnectProviders["contoso"].registration.openIdConnectConfiguration, "omitted") == null
    error_message = "A custom OIDC `registration`'s `clientCredential` and `openIdConnectConfiguration` must be explicit nulls (#378)."
  }

  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.identityProviders.customOpenIdConnectProviders["contoso"].registration.clientId) == "00000000-0000-0000-0000-000000000000", false)
    error_message = "A supplied custom OIDC `client_id` must still reach the body alongside its nulled siblings."
  }
}

// `identityProviders` itself is assigned unconditionally from a local that is
// null when no providers are configured, for the same reason as its children:
// a caller who removes every provider must clear the key, not stop managing it.
run "identity_providers_is_an_explicit_null_when_unconfigured" {
  command = apply

  assert {
    condition     = try(azapi_update_resource.this.body.properties.identityProviders, "omitted") == null
    error_message = "`identityProviders` must be an explicit null when no identity providers are configured, so removing them all clears the property rather than leaving it live (#378)."
  }

  // `login` and `httpSettings.forwardProxy` used conditional merge arms before
  // #377 and are out of scope for the restoration.
  assert {
    condition     = !can(azapi_update_resource.this.body.properties.login)
    error_message = "`login` used a conditional merge arm before #377 and must keep doing so."
  }

  assert {
    condition     = !can(azapi_update_resource.this.body.properties.httpSettings.forwardProxy)
    error_message = "`httpSettings.forwardProxy` used a conditional merge arm before #377 and must keep doing so."
  }

  // The unconditional half of the body is unaffected.
  assert {
    condition     = try(nonsensitive(azapi_update_resource.this.body.properties.platform.enabled) == false, false)
    error_message = "Nulling `identityProviders` must not disturb the rest of the body."
  }
}
