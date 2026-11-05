test {
  parallel = false
}

provider "azapi" {
  use_cli                   = false
  use_msi                   = false
  use_oidc                  = true
  use_aks_workload_identity = false
}

variables {
  # Baseline: input removal is expected to leave the app attached. Flip this
  # after recording the unfixed result; the fixed expectation must fail there.
  expect_configuration_removal_to_clear = false
  # Portal behavior is not yet established. Observe the repair result first.
  enforce_external_repair = false
}

run "deploy_attached_fc1" {
  command   = apply
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }

  assert {
    condition     = output.principal_id != null
    error_message = "The initial app must have a system identity so later runs can detect replacement."
  }
}

run "read_initial_attachment" {
  command = apply

  module {
    source = "./tests/integration/fixtures/read_subnet"
  }

  variables {
    site_id         = run.deploy_attached_fc1.site_id
    subnet_id       = run.deploy_attached_fc1.subnet_id
    phase           = "initial_attachment"
    expect_detached = false
  }
}

run "negative_control_rejects_attached_app_as_detached" {
  command = plan

  module {
    source = "./tests/integration/fixtures/read_subnet"
  }

  # Reuse the reader's state and phase so the GET is known during planning.
  # No mutation or override supplies the result: this reads the attached app.
  variables {
    site_id         = run.deploy_attached_fc1.site_id
    subnet_id       = run.deploy_attached_fc1.subnet_id
    phase           = "initial_attachment"
    expect_detached = true
  }

  expect_failures = [output.checked_subnet]
}

run "plan_input_removal" {
  command   = plan
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }

  variables {
    attach_subnet = false
  }

  assert {
    condition     = output.requested_subnet_id == null
    error_message = "This plan must exercise the caller removing virtual_network_subnet_id."
  }
}

run "apply_input_removal" {
  command   = apply
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }

  variables {
    attach_subnet = false
  }

  assert {
    condition     = output.site_id == run.deploy_attached_fc1.site_id && output.principal_id == run.deploy_attached_fc1.principal_id
    error_message = "Subnet removal must update the original app, not replace it."
  }
}

run "read_input_removal_result" {
  command = apply

  module {
    source = "./tests/integration/fixtures/read_subnet"
  }

  variables {
    site_id         = run.deploy_attached_fc1.site_id
    subnet_id       = run.deploy_attached_fc1.subnet_id
    phase           = "after_input_removal"
    expect_detached = var.expect_configuration_removal_to_clear
  }
}

run "plan_after_input_removal" {
  command   = plan
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }

  variables {
    attach_subnet = false
  }
}

run "restore_configuration" {
  command   = apply
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }

  variables {
    attach_subnet = true
  }
}

run "verify_restored_attachment" {
  command = apply

  module {
    source = "./tests/integration/fixtures/read_subnet"
  }

  variables {
    site_id         = run.deploy_attached_fc1.site_id
    subnet_id       = run.deploy_attached_fc1.subnet_id
    phase           = "before_external_detach"
    expect_detached = false
  }
}

run "detach_outside_site_state" {
  command = apply

  module {
    source = "./tests/integration/fixtures/read_subnet"
  }

  variables {
    site_id         = run.deploy_attached_fc1.site_id
    subnet_id       = run.deploy_attached_fc1.subnet_id
    phase           = "after_external_detach"
    detach_external = true
    expect_detached = true
  }
}

run "refresh_after_external_detach" {
  command   = plan
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }

  plan_options {
    mode = refresh-only
  }
}

run "plan_after_external_detach" {
  command   = plan
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }
}

run "record_external_plan_values" {
  command = apply

  module {
    source = "./tests/integration/fixtures/read_subnet"
  }

  variables {
    site_id                      = run.deploy_attached_fc1.site_id
    subnet_id                    = run.deploy_attached_fc1.subnet_id
    phase                        = "external_detach_plan_values"
    expect_detached              = true
    managed_subnet_after_refresh = run.refresh_after_external_detach.managed_subnet_id
    planned_subnet               = run.plan_after_external_detach.managed_subnet_id
  }
}

run "apply_configured_subnet_after_external_detach" {
  command   = apply
  state_key = "fc1"

  module {
    source = "./tests/integration/fixtures/flex_subnet"
  }

  assert {
    condition     = output.site_id == run.deploy_attached_fc1.site_id && output.principal_id == run.deploy_attached_fc1.principal_id
    error_message = "External-drift repair must not replace the original app."
  }
}

run "read_external_repair_result" {
  command = apply

  module {
    source = "./tests/integration/fixtures/read_subnet"
  }

  variables {
    site_id         = run.deploy_attached_fc1.site_id
    subnet_id       = run.deploy_attached_fc1.subnet_id
    phase           = "after_external_repair_apply"
    expect_detached = var.enforce_external_repair ? false : null
  }
}
