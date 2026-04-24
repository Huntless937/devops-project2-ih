variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "sql_server_name"     { type = string }
variable "sql_database_name"   { type = string }
variable "sql_admin_username"  { type = string }
variable "sql_admin_password"  {
  type      = string
  sensitive = true
}
variable "data_subnet_id"      { type = string }
variable "vnet_id"             { type = string }