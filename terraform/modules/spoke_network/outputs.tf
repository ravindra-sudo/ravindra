output "spoke_vnet_id" {
  value       = azurerm_virtual_network.spoke_vnet.id
  description = "The Resource ID of the Spoke VNet"
}

output "spoke_vnet_name" {
  value       = azurerm_virtual_network.spoke_vnet.name
  description = "The name of the Spoke VNet"
}

output "app_subnet_id" {
  value       = azurerm_subnet.app_subnet.id
  description = "The Resource ID of the Application subnet"
}

output "db_subnet_id" {
  value       = azurerm_subnet.db_subnet.id
  description = "The Resource ID of the Database subnet"
}

output "pe_subnet_id" {
  value       = azurerm_subnet.pe_subnet.id
  description = "The Resource ID of the Private Endpoints subnet"
}
