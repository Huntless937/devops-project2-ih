# Network interfaces — private IPs only, no public IP
resource "azurerm_network_interface" "frontend" {
  name                = "nic-frontend-group7"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.frontend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "backend" {
  name                = "nic-backend-group7"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Frontend VM
resource "azurerm_linux_virtual_machine" "frontend" {
  name                  = "vm-frontend-group7"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.frontend.id]
  zone                  = "2"

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Backend VM
resource "azurerm_linux_virtual_machine" "backend" {
  name                  = "vm-backend-group7"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.backend.id]
  zone                  = "2"

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Public IP for SonarQube (needs to be accessible for scanning)
resource "azurerm_public_ip" "sonarqube" {
  name                = "pip-sonarqube-group7"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
}

# Network interface for SonarQube
resource "azurerm_network_interface" "sonarqube" {
  name                = "nic-sonarqube-group7"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.ops_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sonarqube.id
  }
}

# SonarQube VM
resource "azurerm_linux_virtual_machine" "sonarqube" {
  name                  = "vm-sonarqube-group7"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = "Standard_D2ads_v7"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.sonarqube.id]
  zone                  = "2"

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}
