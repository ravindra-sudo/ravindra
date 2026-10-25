# Spoke Network Module
# Provisions Spoke VNet, Subnets (App, DB, Private Endpoints), NSGs, UDR to Azure Firewall, and Bi-directional Peering.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

resource "azurerm_resource_group" "spoke_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.spoke_rg.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "app_subnet" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.spoke_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = [var.app_subnet_cidr]
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "snet-db"
  resource_group_name  = azurerm_resource_group.spoke_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = [var.db_subnet_cidr]
}

resource "azurerm_subnet" "pe_subnet" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.spoke_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = [var.pe_subnet_cidr]
}

# User Defined Route (UDR) Table - Forces all 0.0.0.0/0 egress to Hub Azure Firewall
resource "azurerm_route_table" "spoke_rt" {
  name                          = "${var.vnet_name}-rt"
  location                      = azurerm_resource_group.spoke_rg.location
  resource_group_name           = azurerm_resource_group.spoke_rg.name
  disable_bgp_route_propagation = false
  tags                          = var.tags

  route {
    name                   = "DefaultEgressToHubFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_firewall_private_ip
  }
}

# Associate Route Table with App and DB Subnets
resource "azurerm_subnet_route_table_association" "app_rt_assoc" {
  subnet_id      = azurerm_subnet.app_subnet.id
  route_table_id = azurerm_route_table.spoke_rt.id
}

resource "azurerm_subnet_route_table_association" "db_rt_assoc" {
  subnet_id      = azurerm_subnet.db_subnet.id
  route_table_id = azurerm_route_table.spoke_rt.id
}

# Bi-directional Peering
# 1. Spoke -> Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${var.vnet_name}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke_rg.name
  virtual_network_name         = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.use_remote_gateways
}

# 2. Hub -> Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-${var.vnet_name}"
  resource_group_name          = var.hub_rg_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}
