output "sql_linked_service_id" {
  value = azurerm_data_factory_linked_service_azure_sql_database.sql.id
}

output "sql_linked_service_name" {
  value = azurerm_data_factory_linked_service_azure_sql_database.sql.name
}
output "key_vault_linked_service_name" {
  description = "Key Vault Linked Service Name"
  value       = azurerm_data_factory_linked_service_key_vault.kv.name
}


output "adls_linked_service_name" {
  description = "ADLS Gen2 Linked Service Name"
  value       = azurerm_data_factory_linked_service_data_lake_storage_gen2.adls.name
} 