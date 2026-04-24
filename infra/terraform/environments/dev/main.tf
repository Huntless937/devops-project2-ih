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
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  vm_size             = var.vm_size
}