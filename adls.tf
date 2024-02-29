resource "azurerm_key_vault_secret" "adls_sp_client_id" {
  key_vault_id = var.key_vault_id
  name         = "${var.product_alias}-adls-${var.org}-client-id"
  value        = azuread_application.adls.application_id
  content_type = "secret"
}

resource "azurerm_key_vault_secret" "adls_sp_client_secret" {
  key_vault_id = var.key_vault_id
  name         = "${var.product_alias}-adls-${var.org}-client-secret"
  value        = azuread_service_principal_password.adls.value
  content_type = "secret"
}

resource "azurerm_key_vault_secret" "adls_sp_file_system" {
  key_vault_id = var.key_vault_id
  name         = "${var.product_alias}-adls-${var.org}-file-system"
  value        = var.source_container
  content_type = "secret"
}

resource "azurerm_key_vault_secret" "adls_sp_storage_account" {
  key_vault_id = var.key_vault_id
  name         = "${var.product_alias}-adls-${var.org}-storage-account"
  value        = var.main_storage_account
  content_type = "secret"
}
