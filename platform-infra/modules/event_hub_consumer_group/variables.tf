variable "resource_group_name" { type = string }
variable "namespace_name" { type = string }
variable "eventhub_name" { type = string }
variable "consumer_group_name" { type = string }

# Optional role assignment for a principal (e.g., Databricks MI) to read from the hub
variable "assign_receiver_role" { 
  type = bool 
  default = false 
}
variable "principal_object_id" { 
  type = string 
  default = "" 
} 