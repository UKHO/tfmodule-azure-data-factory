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
variable "backup_sa_prevent_destroy" {
  default = true
  description = "prevent destroy for the backup storage account"
}



