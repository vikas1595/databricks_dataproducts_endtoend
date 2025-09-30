# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Storage Account for ADLS Gen2
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled          = true
  tags                     = var.tags
}

# ADLS Gen2 Container
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
# root container
resource "azurerm_storage_container" "root_container" {
  name                  = "root"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"
  tags                       = var.tags
}

# Key Vault Access Policy for admin
resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.admin_object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"
  ]
}

# Event Hubs Namespace
resource "azurerm_eventhub_namespace" "namespace" {
  name                = var.eventhub_namespace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
  tags                = var.tags
}

# Event Hub
resource "azurerm_eventhub" "hub" {
  name                = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}

# Access Connector for Databricks
resource "azurerm_databricks_access_connector" "connector" {
  name                = var.access_connector_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.tags
  identity {
    type = "SystemAssigned"
  }
}

# Local for Access Connector MI principal id
locals {
  access_connector_principal_id = try(azurerm_databricks_access_connector.connector.identity[0].principal_id, null)
}

# Grant UC access connector identity rights on storage
resource "azurerm_role_assignment" "ac_storage_blob_owner" {
  count                             = 0
  scope                              = azurerm_storage_account.storage.id
  role_definition_name               = "Storage Blob Data Owner"
  principal_id                       = local.access_connector_principal_id
  skip_service_principal_aad_check   = true
  depends_on                         = [ azurerm_databricks_access_connector.connector ]
}

# Grant SPN rights on storage (Storage Blob Data Owner)
# resource "azurerm_role_assignment" "spn_storage_blob_owner" {
#   scope                = azurerm_storage_account.storage.id
#   role_definition_name = "Storage Blob Data Owner"
#   principal_id         = var.admin_object_id
# }

# Data Factory
resource "azurerm_data_factory" "adf" {
  name                = var.data_factory_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}


# Data source for current client config
data "azurerm_client_config" "current" {} 