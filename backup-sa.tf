resource "azurerm_storage_account" "backup" {
  name                             = "${var.product_alias}${var.environment_name}backupstore${var.org}"
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_tier                     = "Standard"
  access_tier                      = "Cool"
  account_replication_type         = "ZRS"
  is_hns_enabled                   = true
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  min_tls_version                  = "TLS1_2"

  account_kind = "StorageV2"

  lifecycle {
    ignore_changes = [tags]
  }

  network_rules {
  default_action             = "Deny"
  ip_rules                   = var.org_ip_addresses
  virtual_network_subnet_ids = concat([var.subnet_ids], var.build_agent_subnet_ids)
  bypass                     = ["AzureServices"]
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data-lake-backup" {
  name               = "adls-backup"
  storage_account_id = azurerm_storage_account.backup.id
  depends_on         = [ azurerm_storage_account.backup ]
}

resource "azurerm_key_vault_secret" "backup_storage_key" {
  key_vault_id = var.key_vault_id
  provider     = azurerm.sub
  name         = "backup-storage-key"
  value        = azurerm_storage_account.backup.primary_access_key
  content_type = "secret"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_management_lock" "adls_lock" {
  name       = "adls-storageaccount-lock"
  scope      = azurerm_storage_account.backup.id
  lock_level = "CanNotDelete"
  notes      = "To protect Prod Data"
  count      = var.environment_name == "live" ? 1: 0
}
