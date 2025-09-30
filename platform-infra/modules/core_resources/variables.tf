variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

# Storage account for ADLS Gen2
variable "storage_account_name" { type = string }
variable "container_name" {
  type    = string
  default = "lake"
}

# Key Vault
variable "key_vault_name" { type = string }
variable "admin_object_id" { type = string }

# Event Hubs
variable "eventhub_namespace_name" { type = string }
variable "eventhub_name" {
  type    = string
  default = "orders"
}

# Data Factory
variable "data_factory_name" { type = string }

# Access Connector for Databricks
variable "access_connector_name" { type = string } 