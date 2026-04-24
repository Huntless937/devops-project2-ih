output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.subnets : k => s.id }
}

output "subnet_address_prefixes" {
  value = { for k, s in azurerm_subnet.subnets : k => s.address_prefixes[0] }
}