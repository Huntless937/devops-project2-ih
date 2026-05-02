resource "azurerm_virtual_network" "main" {
  name                = "vnet-burgerbuilder-group7"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
}

# NSG for frontend subnet — allow only from App Gateway
resource "azurerm_network_security_group" "frontend" {
  name                = "nsg-frontend-group7"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-appgw-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
  name                       = "allow-ssh-from-ops"
  priority                   = 150
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "10.0.4.0/24"
  destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG for backend subnet — allow only from App Gateway
resource "azurerm_network_security_group" "backend" {
  name                = "nsg-backend-group7"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-appgw-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh-from-ops"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.4.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSGs to subnets
resource "azurerm_subnet_network_security_group_association" "frontend" {
  subnet_id                 = azurerm_subnet.subnets["frontend"].id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.subnets["backend"].id
  network_security_group_id = azurerm_network_security_group.backend.id
}

# NSG for ops subnet
resource "azurerm_network_security_group" "ops" {
  name                = "nsg-ops-group7"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-ssh-from-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-sonarqube"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ops" {
  subnet_id                 = azurerm_subnet.subnets["ops"].id
  network_security_group_id = azurerm_network_security_group.ops.id
}
