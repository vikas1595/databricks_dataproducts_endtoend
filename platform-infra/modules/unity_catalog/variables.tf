variable "product_name" { type = string }
variable "storage_account_name" { type = string }
variable "storage" {
  type = object({
    container = string
    base_path = string
  })
}
variable "rbac" {
  type = object({
    admin_group    = string
    producer_group = string
    consumer_group = string
  })
}
variable "access_connector_id" { type = string } 