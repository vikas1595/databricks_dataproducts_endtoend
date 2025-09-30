resource "azurerm_eventhub_consumer_group" "cg" {
  name                = var.consumer_group_name
  namespace_name      = var.namespace_name
  eventhub_name       = var.eventhub_name
  resource_group_name = var.resource_group_name
}

# Assign Azure Event Hubs Data Receiver role to the principal (optional)
resource "azurerm_role_assignment" "receiver" {
  count                = var.assign_receiver_role && var.principal_object_id != "" ? 1 : 0
  scope                = azurerm_eventhub_consumer_group.cg.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = var.principal_object_id
} 