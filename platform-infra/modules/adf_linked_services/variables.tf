variable "data_factory_id" { type = string }
variable "key_vault_id" { type = string }
variable "storage_account_name" { type = string }
variable "storage_account_id" { type = string }
variable "sql_server" { type = string }
variable "sql_database" { type = string }
variable "sql_username" { type = string }
variable "sql_password" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}