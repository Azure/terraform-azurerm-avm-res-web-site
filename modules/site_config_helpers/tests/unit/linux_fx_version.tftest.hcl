# Expected strings come from `az webapp list-runtimes --os linux`, which reports
# configs such as `JAVA|11-java11`, `JAVA|8-jre8`, `TOMCAT|10.1-java11`, and
# `JBOSSEAP|7-java11`.

variables {
  os_type = "Linux"
}

run "java_defaults_container_to_java" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version = "21"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "JAVA|21-java21"
    error_message = "Expected `JAVA|21-java21`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "java_with_explicit_container" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "21"
          java_container         = "JAVA"
          java_container_version = "21"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "JAVA|21-java21"
    error_message = "Expected `JAVA|21-java21`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "java_fully_qualified_version_has_no_suffix" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "11"
          java_container         = "JAVA"
          java_container_version = "11.0.13"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "JAVA|11.0.13"
    error_message = "Expected `JAVA|11.0.13`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "java_8_uses_jre_suffix" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "8"
          java_container         = "JAVA"
          java_container_version = "8"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "JAVA|8-jre8"
    error_message = "Expected `JAVA|8-jre8`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "tomcat_puts_container_version_first" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "17"
          java_container         = "TOMCAT"
          java_container_version = "10.1"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "TOMCAT|10.1-java17"
    error_message = "Expected `TOMCAT|10.1-java17`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "tomcat_container_name_is_normalized" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "11"
          java_container         = "tomcat"
          java_container_version = "9.0"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "TOMCAT|9.0-java11"
    error_message = "Expected `TOMCAT|9.0-java11`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "tomcat_on_java_8_uses_jre_suffix" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "8"
          java_container         = "TOMCAT"
          java_container_version = "9.0"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "TOMCAT|9.0-jre8"
    error_message = "Expected `TOMCAT|9.0-jre8`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "tomcat_on_java_8_with_patch_version_uses_java_suffix" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "8"
          java_container         = "TOMCAT"
          java_container_version = "10.0.20"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "TOMCAT|10.0.20-java8"
    error_message = "Expected `TOMCAT|10.0.20-java8`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "jbosseap_puts_container_version_first" {
  command = apply

  variables {
    site_config = {
      application_stack = {
        java = {
          java_version           = "11"
          java_container         = "JBOSSEAP"
          java_container_version = "7"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == "JBOSSEAP|7-java11"
    error_message = "Expected `JBOSSEAP|7-java11`, got `${coalesce(output.linux_fx_version, "null")}`."
  }
}

run "windows_uses_dedicated_java_properties" {
  command = apply

  variables {
    os_type = "Windows"
    site_config = {
      application_stack = {
        java = {
          java_version           = "17"
          java_container         = "TOMCAT"
          java_container_version = "10.1"
        }
      }
    }
  }

  assert {
    condition     = output.linux_fx_version == null
    error_message = "Windows sites should not set `linuxFxVersion`."
  }

  assert {
    condition     = output.java_version == "17" && output.java_container == "TOMCAT" && output.java_container_version == "10.1"
    error_message = "Windows sites should pass the Java properties through unchanged."
  }
}
