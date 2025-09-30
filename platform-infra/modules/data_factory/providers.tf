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

