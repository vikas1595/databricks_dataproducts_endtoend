locals {
  sql_sources = {
    for s in var.sources : s.name => s if try(s.type, "") == "sqlserver"
  }
}

resource "azurerm_data_factory_dataset_azure_sql_table" "src" {
  for_each            = local.sql_sources
  name                = "ds_${var.product_name}_${each.key}_src"
  data_factory_id     = var.data_factory_id
  linked_service_id = var.sql_linked_service_id
  schema              = each.value.schema
  table               = each.value.table
}

resource "azurerm_data_factory_dataset_delimited_text" "sink" {
  for_each            = local.sql_sources
  name                = "ds_${var.product_name}_${each.key}_sink"
  data_factory_id     = var.data_factory_id
  linked_service_name = var.adls_linked_service_name
  folder              = "${var.product_name}/datasets"
  parameters = {
    basePath = ""
  }
  column_delimiter    = ","
  encoding            = "UTF-8"
  azure_blob_fs_location {
    file_system = "lake" # or use var.container_name if parameterized
    path        = "${var.product_name}/datasets"
  }
}

resource "azurerm_data_factory_pipeline" "copy" {
  for_each        = local.sql_sources
  name            = "pl_${var.product_name}_${each.key}_incremental"
  data_factory_id = var.data_factory_id
  parameters = {
    schema           = each.value.schema
    table            = each.value.table
    watermarkColumn  = try(each.value.watermark_column, "")
    basePath         = var.bronze_basepath
  }
  annotations = ["self-service", var.product_name]
  depends_on = [azurerm_data_factory_dataset_azure_sql_table.src, azurerm_data_factory_dataset_delimited_text.sink]
}

resource "azurerm_data_factory_trigger_schedule" "trg" {
  for_each        = { for k, s in local.sql_sources : k => s if try(s.schedule, "") != "" && try(s.schedule, "") != "streaming" }
  name            = "trg_${var.product_name}_${each.key}"
  data_factory_id = var.data_factory_id
  interval        = 1
  frequency       = "Hour"
  pipeline_name   = azurerm_data_factory_pipeline.copy[each.key].name
} 