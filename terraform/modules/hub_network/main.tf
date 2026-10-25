# Hub Network Module
# Provisions the centralized Hub VNet, Azure Firewall, GatewaySubnet, and Bastion Subnet.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

resource "azurerm_resource_group" "hub_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnet for VPN / ExpressRoute Gateway (Fixed naming required by Azure)
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.gateway_subnet_cidr]
}

# Subnet for Azure Firewall (Fixed naming required by Azure)
resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

# Azure Firewall Public IP
resource "azurerm_public_ip" "fw_pip" {
  name                = "${var.vnet_name}-fw-pip"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

# Azure Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                = "${var.vnet_name}-fw-policy"
  resource_group_name = azurerm_resource_group.hub_rg.name
  location            = azurerm_resource_group.hub_rg.location
  sku                 = "Standard"
  tags                = var.tags

  dns {
    proxy_enabled = true
  }
}

# Azure Firewall Instance
resource "azurerm_firewall" "hub_firewall" {
  name                = "${var.vnet_name}-firewall"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  zones               = ["1", "2", "3"]
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}
