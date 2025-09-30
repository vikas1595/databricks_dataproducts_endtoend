terraform {
  required_version = ">= 1.5.0, <= 1.5.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.77.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.87.1"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true # something when local running?
  features {}
}

provider "databricks" {
  host                        = azurerm_databricks_workspace.workspace.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.workspace.id
  azure_client_id             = var.client_id       # SPN application ID
  azure_client_secret         = var.client_secret   # SPN secret
  azure_tenant_id             = var.tenant_id       # Tenant ID
  auth_type                   = "azure-client-secret"
}

provider "databricks" {
  alias                       = "account"
  host                        = "https://accounts.azuredatabricks.net"
  account_id                  = var.databricks_account_id
  azure_client_id             = var.client_id
  azure_client_secret         = var.client_secret
  azure_tenant_id             = var.tenant_id
  auth_type                   = "azure-client-secret"
}