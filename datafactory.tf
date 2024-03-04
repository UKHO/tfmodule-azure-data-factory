
resource "azurerm_data_factory" "this" {
  name                   = "${var.org}-${var.name}-adf-${var.environment_name}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  public_network_enabled = false
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

data "azurerm_private_dns_zone" "dnszone" {
  provider                = azurerm.hub
  name                    = "privatelink.datafactory.azure.net"
  resource_group_name     = var.dns_zone_rg
}

resource "azurerm_private_endpoint" "data_factory" {
  
  name                = "${var.product_alias}-${var.environment_name}-adf-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.pe_subnet_id
  depends_on          = [ azurerm_data_factory.this ]

  private_service_connection {
    name                           = "${var.product_alias}-${var.environment_name}-adf-pe-psc"
    private_connection_resource_id = azurerm_data_factory.this.id
    is_manual_connection           = false
    subresource_names              = ["datafactory"]
  }
  private_dns_zone_group {
    name                 = "${var.product_alias}-adf-dns-group-${var.environment_name}"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dnszone.id]
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "linkdns" {
  provider              = azurerm.hub
  name                  = "${var.product_alias}-adf-dns-link-${var.environment_name}"
  resource_group_name   = var.dns_zone_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = var.virtual_network_id
  
  lifecycle {
    ignore_changes = [tags]
  }
}


resource "azurerm_role_assignment" "data_lake_storage_read" {
  scope                = var.main_storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "backup_storage_write" {
  scope                = azurerm_storage_account.backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
}

resource "azurerm_data_factory_pipeline" "incremental_backup" {
  name            = "${var.environment_name}DataLakeBackupIncremental"
  data_factory_id = azurerm_data_factory.this.id

  parameters = {
    ScheduledTriggerTime : "Variable not set"
  }
  activities_json = templatefile("${path.module}/data-factory-pipeline-incremental.tpl", { sourceDataset = azurerm_data_factory_dataset_binary.data_lake_dataset.name, sinkDataset = azurerm_data_factory_dataset_binary.backup_dataset.name })
}

resource "azurerm_data_factory_pipeline" "full_backup" {
  name            = "${var.environment_name}DataLakeBackupFull"
  data_factory_id = azurerm_data_factory.this.id

  parameters = {
    ScheduledTriggerTime : "Variable not set"
  }
  activities_json = templatefile("${path.module}/data-factory-pipeline-full.tpl", { sourceDataset = azurerm_data_factory_dataset_binary.data_lake_dataset.name, sinkDataset = azurerm_data_factory_dataset_binary.backup_dataset.name })
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "data_lake_storage" {
  name                 = "${var.environment_name}DataLakeStorageService"
  data_factory_id      = azurerm_data_factory.this.id
  use_managed_identity = true
  url                  = var.main_storage_account_primary_dfs_endpoint
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "backup_storage" {
  name                 = "${var.environment_name}BackupStorageService"
  data_factory_id      = azurerm_data_factory.this.id
  use_managed_identity = true
  url                  = azurerm_storage_account.backup.primary_dfs_endpoint
}

resource "azurerm_data_factory_dataset_binary" "data_lake_dataset" {
  # Dataset resources can't currently be updated due to a bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/11650
  # To modify this resource you will need to manually delete it first

  name                = "${var.environment_name}DataLakeStorageDataset"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.data_lake_storage.name

  azure_blob_storage_location {
    container = var.source_container
    path      = "**"
    filename  = "**"
  }
}

resource "azurerm_data_factory_dataset_binary" "backup_dataset" {
  # Dataset resources can't currently be updated due to a bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/11650
  # To modify this resource you will need to manually delete it first

  name                = "${var.environment_name}BackupStorageDataset"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.backup_storage.name
  parameters = {
    OutputPath = "Variable not set"
  }

  azure_blob_storage_location {
    container = azurerm_storage_data_lake_gen2_filesystem.data-lake-backup.name
    #path      = "@dataset().OutputPath" # Leaving this blank but can set a custom path if needed
    filename  = "@concat('','')" # This should not be set, however the Terraform provider requires this to be present and not empty.
  }
}

resource "azurerm_data_factory_trigger_schedule" "incremental" {
  name            = "${var.environment_name}IncrementalTrigger"
  data_factory_id = azurerm_data_factory.this.id
  pipeline_name   = azurerm_data_factory_pipeline.incremental_backup.name
  pipeline_parameters = {
    "ScheduledTriggerTime" : "@trigger().scheduledTime"
  }
  time_zone  = "UTC"
  start_time = "2018-01-01T00:00:00Z"
  interval   = 2
  frequency  = "Hour"
}

resource "azurerm_data_factory_trigger_schedule" "full" {
  name            = "${var.environment_name}FullTrigger"
  data_factory_id = azurerm_data_factory.this.id
  pipeline_name   = azurerm_data_factory_pipeline.full_backup.name
  pipeline_parameters = {
    "ScheduledTriggerTime" : "@trigger().scheduledTime"
  }
  time_zone  = "UTC"
  start_time = "2018-01-01T00:00:00Z"
  interval   = 1
  frequency  = "Week"
}
