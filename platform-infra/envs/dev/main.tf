module "core_resources" {
  source                   = "../../modules/core_resources"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  storage_account_name     = var.storage_account_name
  container_name           = "lake"
  key_vault_name           = var.key_vault_name
  admin_object_id          = var.object_id
  eventhub_namespace_name  = var.eventhub_namespace_name
  eventhub_name            = "orders"
  data_factory_name        = var.data_factory_name
  access_connector_name    = var.access_connector_name
  tags                     = var.tags
}
# Core Infrastructure

# Databricks Workspace (env-level)
resource "azurerm_databricks_workspace" "workspace" {
  name                = var.databricks_workspace_name
  resource_group_name = module.core_resources.resource_group_name
  location            = var.location
  sku                 = "premium"
  tags                = var.tags
}

# Derive Databricks workspace_id from workspace_url
locals {
  workspace_id_match = regex("adb-[0-9]+", azurerm_databricks_workspace.workspace.workspace_url)
  workspace_id       = replace(local.workspace_id_match, "adb-", "")
}

# # Unity Catalog Metastore (Account-level)
# resource "databricks_metastore" "primary" {
#   count        = 0
#   provider     = databricks.account
#   name         = "uc-${var.tags.env}"
#   storage_root = "abfss://root@${module.core_resources.storage_account_name}.dfs.core.windows.net/unitycatalog"
#   region       = var.location
# }

# # Assign Metastore to Workspace
# resource "databricks_metastore_assignment" "ws" {
#   count                = 0
#   provider             = databricks.account
#   metastore_id         = databricks_metastore.primary.id
#   workspace_id         = local.workspace_id
#   default_catalog_name = "main"
# }

# ADF Linked Services
module "adf_linked_services" {
  source = "../../modules/adf_linked_services"
  
  data_factory_id     = module.core_resources.data_factory_id
  key_vault_id        = module.core_resources.key_vault_id
  storage_account_name = module.core_resources.storage_account_name
  storage_account_id   = module.core_resources.storage_account_id
  sql_server          = var.sql_server
  sql_database        = var.sql_database
  sql_username        = var.sql_username
  sql_password        = var.sql_password
  tags                = var.tags
  depends_on = [ module.core_resources  ]
}

# Product-specific resources
locals {
  product_files = fileset("${path.module}/../../metadata/products", "*.yaml")
  products = {
    for f in local.product_files :
    trimsuffix(basename(f), ".yaml") => yamldecode(file("${path.module}/../../metadata/products/${f}"))
  }
}

module "product_uc" {
  providers = {
    databricks.account = databricks.account
  }
  for_each               = local.products
  source                 = "../../modules/unity_catalog"
  product_name           = each.value.product.name
  storage_account_name   = module.core_resources.storage_account_name
  storage                = each.value.storage
  rbac                   = each.value.governance.rbac
  access_connector_id    = module.core_resources.access_connector_id
  depends_on = [ module.core_resources ]
}

module "product_adf" {
  for_each                   = local.products
  source                     = "../../modules/data_factory"
  product_name               = each.value.product.name
  data_factory_id            = module.core_resources.data_factory_id
  bronze_basepath            = each.value.medallion.bronze_path
  sources                    = each.value.sources
  sql_linked_service_id      = module.adf_linked_services.sql_linked_service_id
  sql_linked_service_name    = module.adf_linked_services.sql_linked_service_name
  adls_linked_service_name   = module.adf_linked_services.adls_linked_service_name
  depends_on = [ module.core_resources  ]
}

module "product_eh_cg" {
  for_each = {
    for item in flatten([
      for p_name, p in local.products : [
        for s in p.sources : {
          product = p.product.name
          src     = s
        } if try(s.type, "") == "eventhub"
      ]
    ]) : "${item.product}_${item.src.name}" => item
  }
  source = "../../modules/event_hub_consumer_group"

  resource_group_name = module.core_resources.resource_group_name
  namespace_name      = module.core_resources.eventhub_namespace_name
  eventhub_name       = module.core_resources.eventhub_name
  consumer_group_name = try(each.value.src.consumer_group, "cg-${each.value.product}")
  depends_on = [ module.core_resources  ]
} 