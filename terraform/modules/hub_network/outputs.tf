output "hub_vnet_id" {
  value       = azurerm_virtual_network.hub_vnet.id
  description = "The Resource ID of the Hub VNet"
}

output "hub_vnet_name" {
  value       = azurerm_virtual_network.hub_vnet.name
  description = "The name of the Hub VNet"
}

output "hub_rg_name" {
  value       = azurerm_resource_group.hub_rg.name
  description = "The name of the Hub resource group"
}

output "firewall_private_ip" {
  value       = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  description = "The private IP address of Azure Firewall for UDR next-hop routing"
}

output "firewall_public_ip" {
  value       = azurerm_public_ip.fw_pip.ip_address
  description = "The public IP address of the Azure Firewall"
}
