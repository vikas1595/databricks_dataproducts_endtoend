# Key Vault Linked Service
resource "azurerm_data_factory_linked_service_key_vault" "kv" {
  name                = "ls_keyvault"
  data_factory_id     = var.data_factory_id
  key_vault_id        = var.key_vault_id
}

# SQL Server Linked Service
resource "azurerm_data_factory_linked_service_azure_sql_database" "sql" {
  name            = "ls_sql_src"
  data_factory_id = var.data_factory_id
  connection_string = "Server=tcp:${var.sql_server},1433;Database=${var.sql_database};User ID=${var.sql_username};Password=${var.sql_password};TrustServerCertificate=true;"
}

# ADLS Gen2 Linked Service
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adls" {
  name                  = "ls_adls"
  data_factory_id       = var.data_factory_id
  url                   = "https://${var.storage_account_name}.dfs.core.windows.net"
  service_principal_id  = data.azurerm_client_config.current.client_id
  service_principal_key = var.sql_password  # We'll use the SPN secret here
  tenant                = data.azurerm_client_config.current.tenant_id
}

# Data source for current client config
data "azurerm_client_config" "current" {} 