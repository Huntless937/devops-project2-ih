output "frontend_vm_id" {
  value = azurerm_linux_virtual_machine.frontend.id
}

output "backend_vm_id" {
  value = azurerm_linux_virtual_machine.backend.id
}

output "frontend_private_ip" {
  value = azurerm_network_interface.frontend.private_ip_address
}

output "backend_private_ip" {
  value = azurerm_network_interface.backend.private_ip_address
}

output "frontend_vm_identity" {
  value = azurerm_linux_virtual_machine.frontend.identity[0].principal_id
}

output "backend_vm_identity" {
  value = azurerm_linux_virtual_machine.backend.identity[0].principal_id
}