# Azure SPN Information
variable "subscription_id" { type = string }
variable "client_id" { type = string }
variable "object_id" { type = string }
variable "tenant_id" { type = string }
variable "client_secret" { type = string }

# Databricks Account
variable "databricks_account_id" { type = string }

# Location
variable "location" { type = string }

# Resource names
variable "resource_group_name" { type = string }
variable "storage_account_name" { type = string }
variable "key_vault_name" { type = string }
variable "eventhub_namespace_name" { type = string }
variable "databricks_workspace_name" { type = string }
variable "data_factory_name" { type = string }
variable "access_connector_name" { type = string }

# SQL Server connection
variable "sql_server" { type = string }
variable "sql_database" { type = string }
variable "sql_username" { type = string }
variable "sql_password" { type = string }

# Tags
variable "tags" { 
  type = map(string) 
  default = {} 
} 