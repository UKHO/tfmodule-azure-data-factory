# Terraform Module: for Azure Data Factory 

## Compatibility

- **Terraform:** >= 1.2.0
- **Azure Provider (azurerm):** >= 3.54 (supports both 3.54 and 4.54+)
- **Azure AD Provider (azuread):** >= 2.0

##

## Required Resources

- `Resource Group` exists or is created external to the module.
- `Provider` must be created external to the module.
- Grant `terraform-service account` permission to create records in the respective private dns zones for the private endpoint
- The `terraform-service account` that will deploy this module will need Application Administrator role in order to create the ADLS Service Principal

## Usage

## IMPORTANT - If you require DNS records and vnet links to be created in the private dns zones make sure the terraform-SOMETHING account has "read" over core services resource group (business-rg or engineering-rg) and "contributor" on the private dns zone you require.


```terraform

## Usage Vars

variable "name" {
  type = string
  description = "Name of the product/subscription"
}
variable "product_alias" {
  type = string
  description = "The alias for the project"
}
variable "environment_name" {
  type = string
  description = "Name of the environmet the resource will run in"
}
variable "location" {
  type = string
  description = "Location the resource will run in"
}
variable "resource_group_name" {
  type = string
  description = "Resource Group name"
}
variable "org" {
  description = "Organisation"
}
variable "main_storage_account" {
  description = "Main ADLS storage account name"
}
variable "main_storage_account_id" {
  description = "Main ADLS storage account id"
}
variable "key_vault_id" {
  description = "Main key vault id"
}
variable "org_ip_addresses" {
  #type        = list(string)
  description = "external-facing IP addresses"
}
variable "build_agent_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for build agents"
}
variable "subnet_ids" {
  description = "ID's of main subnet"
}
variable "pe_subnet_id" {
  description = "ID's of PE subnet"
}
variable "virtual_network_id" {
  description = "id of vnet"
}
variable "dns_zone_rg" {
  description = "the resource group of the dns zone"
}
variable "main_storage_account_primary_dfs_endpoint" {
  description = "dfs endpoint for main storage account"
}
variable "source_container" {
  description = "source container that the data is being backed up from"
}
variable "alert_email_address" {
description = "Email Address for alerts"
}

#Example ref

module "data_factory" {
    source    = "github.com/UKHO/tfmodule-azure-data-factory?ref=v1.2.0"
    providers = {
    azurerm.sub = azurerm.sub
    azurerm.hub = azurerm.hub
}
depends_on                                = [# Refer to existing SA]
main_storage_account                      = var.main_sa
main_storage_account_id                   = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Storage/storageAccounts/%s", var.subscription_id, var.rg, azurerm_storage_account.edu_storage_account_data.name)
main_storage_account_primary_dfs_endpoint = var.main_sa_dfs_endpoint
source_container                          = var.source_container
product_alias                             = var.alias
name                                      = var.name
environment_name                          = var.environment
location                                  = var.location
resource_group_name                       = var.rg
virtual_network_id                        = var.vnet_id
key_vault_id                              = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg}/providers/Microsoft.KeyVault/vaults/${var.key_vault}"
subnet_ids                                = var.subnet_ids
pe_subnet_id                              = var.pe_subnet_id
dns_zone_rg                               = var.dns_resource_group
org_ip_addresses                          = var.org_ips
build_agent_subnet_ids                    = var.agent_subnet_ids
alert_email_address                       = var.alert_email_address 
}
```