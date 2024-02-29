resource "random_uuid" "adls" {}

resource "time_rotating" "one_year" {
  rotation_days = 365
}

data "azuread_client_config" "current" {}

resource "azuread_application" "adls" {
  display_name = "${var.product_alias}-${var.environment_name}-adls-${var.org}"
  owners = [
    data.azuread_client_config.current.object_id
  ]
  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${var.product_alias}-${var.environment_name}-adls-${var.org} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${var.product_alias}-${var.environment_name}-adls-${var.org}"
      enabled                    = true
      id                         = random_uuid.adls.result
      type                       = "User"
      user_consent_description   = "Allow the application to access ${var.product_alias}-${var.environment_name}-adls-${var.org} on your behalf."
      user_consent_display_name  = "Access ${var.product_alias}-${var.environment_name}-adls-${var.org}"
      value                      = "user_impersonation"
    }
  }
  web {
    implicit_grant {
      id_token_issuance_enabled = true
    }
  }
}

resource "azuread_service_principal" "adls" {
  client_id = azuread_application.adls.application_id
  owners = [
    data.azuread_client_config.current.object_id
  ]
}

resource "azuread_service_principal_password" "adls" {
  service_principal_id = azuread_service_principal.adls.id
  rotate_when_changed = {
    rotation = time_rotating.one_year.id
  }
}
