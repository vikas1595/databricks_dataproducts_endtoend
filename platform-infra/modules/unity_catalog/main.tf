resource "databricks_storage_credential" "cred" {
  provider = databricks.account
  name = "${var.product_name}-cred"
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
}

resource "databricks_external_location" "loc" {
  name            = "${var.product_name}-loc"
  url             = "abfss://${var.storage.container}@${var.storage_account_name}.dfs.core.windows.net${var.storage.base_path}"
  credential_name = databricks_storage_credential.cred.name
}

resource "databricks_catalog" "catalog" {
  name         = var.product_name
  comment      = "Catalog for data product ${var.product_name}"
}

resource "databricks_schema" "bronze" {
  catalog_name = databricks_catalog.catalog.name
  name         = "bronze"
}

resource "databricks_schema" "silver" {
  catalog_name = databricks_catalog.catalog.name
  name         = "silver"
}

resource "databricks_schema" "gold" {
  catalog_name = databricks_catalog.catalog.name
  name         = "gold"
}

resource "databricks_grants" "catalog_grants" {
  catalog = databricks_catalog.catalog.name
  grant {
    principal  = var.rbac.admin_group
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = var.rbac.producer_group
    privileges = ["USE_CATALOG", "CREATE", "USE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT"]
  }
  grant {
    principal  = var.rbac.consumer_group
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }
}

resource "databricks_grants" "ext_loc_grants" {
  external_location = databricks_external_location.loc.name
  grant {
    principal  = var.rbac.producer_group
    privileges = ["READ_FILES", "WRITE_FILES", "CREATE_TABLE"]
  }
} 