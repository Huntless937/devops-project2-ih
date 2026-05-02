terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-Group7"
    storage_account_name = "tfstategroupp7"
    container_name       = "tfstatecontainergroupp7"
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Resource group for everything
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Call the network module
module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
}

module "compute" {
  source              = "../../modules/compute"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  frontend_subnet_id  = module.network.subnet_ids["frontend"]
  backend_subnet_id   = module.network.subnet_ids["backend"]
  ops_subnet_id       = module.network.subnet_ids["ops"]
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  vm_size             = var.vm_size
}

module "database" {
  source              = "../../modules/database"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sql_server_name     = var.sql_server_name
  sql_database_name   = var.sql_database_name
  sql_admin_username  = var.sql_admin_username
  sql_admin_password  = var.sql_admin_password
  data_subnet_id      = module.network.subnet_ids["data"]
  vnet_id             = module.network.vnet_id
}

module "appgateway" {
  source              = "../../modules/appgateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  appgw_subnet_id     = module.network.subnet_ids["appgw"]
  frontend_private_ip = module.compute.frontend_private_ip
  backend_private_ip  = module.compute.backend_private_ip
  ssl_cert_data       = var.ssl_cert_data
  ssl_cert_password   = var.ssl_cert_password
}

module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  alert_email         = var.alert_email
  appgw_id            = module.appgateway.appgw_id
  frontend_vm_id      = module.compute.frontend_vm_id
  backend_vm_id       = module.compute.backend_vm_id
  sql_database_id     = module.database.sql_database_id
}
