variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "appgw_subnet_id"     { type = string }
variable "frontend_private_ip" { type = string }
variable "backend_private_ip"  { type = string }
variable "ssl_cert_data"     { 
  type      = string
  sensitive = true
}
variable "ssl_cert_password" {
  type      = string
  sensitive = true
}
