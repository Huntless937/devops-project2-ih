variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "alert_email"         { type = string }
variable "appgw_id"            { type = string }
variable "frontend_vm_id"      { type = string }
variable "backend_vm_id"       { type = string }
variable "sql_database_id"     { type = string }
variable "telegram_bot_token" {
  type      = string
  sensitive = true
}

variable "telegram_chat_id" {
  type      = string
  sensitive = true
}
