variable "resource_group_name" {
  type    = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
}

variable "admin_username" {
  type    = string
  default = "azureuser-group7"
}

variable "ssh_public_key" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "sql_server_name"    { type = string }
variable "sql_database_name"  { type = string }
variable "sql_admin_username" { type = string }
variable "sql_admin_password" {
  type      = string
  sensitive = true
}