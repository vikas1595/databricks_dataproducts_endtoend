# Azure SPN Information
subscription_id = 
client_id = 
object_id = 
tenant_id = 

# Databricks Account
# Replace with your Databricks account id from the Accounts console
databricks_account_id = 

# Location
location = 

# Resource names (these will be created)
resource_group_name = "rg-data-platform-dev"
storage_account_name = "stdataplatformde49dev"
key_vault_name = "kv-dataplatformde49-dev"
eventhub_namespace_name = "ehns-data-platform-dev"
databricks_workspace_name = "dbx-data-platform-dev"
data_factory_name = "adf-data-platform-de49-dev"
access_connector_name = "ac-data-platform-dev"

# SQL Server connection (you'll need to provide these)
sql_server = "<your-sql-server>.database.windows.net"
sql_database = "<your-sql-database>"
sql_username = "<your-sql-username>"
sql_password = ""
# Tags
tags = {
  env = "dev"
  project = "data-platform"
  managed_by = "terraform"
} 