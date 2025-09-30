output "resource_group_id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_id" {
  description = "Storage Account ID"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  description = "Storage Account Name"
  value       = azurerm_storage_account.storage.name
}

output "container_name" {
  description = "ADLS Container Name"
  value       = azurerm_storage_container.container.name
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "Key Vault Name"
  value       = azurerm_key_vault.kv.name
}

output "eventhub_namespace_id" {
  description = "Event Hub Namespace ID"
  value       = azurerm_eventhub_namespace.namespace.id
}

output "eventhub_namespace_name" {
  description = "Event Hub Namespace Name"
  value       = azurerm_eventhub_namespace.namespace.name
}

output "eventhub_id" {
  description = "Event Hub ID"
  value       = azurerm_eventhub.hub.id
}

output "eventhub_name" {
  description = "Event Hub Name"
  value       = azurerm_eventhub.hub.name
}

output "access_connector_id" {
  description = "Databricks Access Connector ID"
  value       = azurerm_databricks_access_connector.connector.id
}

output "access_connector_full" {
  description = "Managed Identity principalId for Databricks Access Connector"
  value       = azurerm_databricks_access_connector.connector
}

output "data_factory_id" {
  description = "Data Factory ID"
  value       = azurerm_data_factory.adf.id
}

output "data_factory_name" {
  description = "Data Factory Name"
  value       = azurerm_data_factory.adf.name
}
