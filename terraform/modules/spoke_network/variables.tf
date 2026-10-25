variable "resource_group_name" {
  type        = string
  description = "The name of the Spoke resource group"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"
  default     = "eastus"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Spoke Virtual Network"
}

variable "address_space" {
  type        = list(string)
  description = "CIDR address space for the Spoke VNet"
}

variable "app_subnet_cidr" {
  type        = string
  description = "CIDR block for Application tier subnet"
}

variable "db_subnet_cidr" {
  type        = string
  description = "CIDR block for Database tier subnet"
}

variable "pe_subnet_cidr" {
  type        = string
  description = "CIDR block for Private Endpoints subnet"
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the Hub VNet for peering"
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the Hub VNet"
}

variable "hub_rg_name" {
  type        = string
  description = "Name of the Hub Resource Group"
}

variable "hub_firewall_private_ip" {
  type        = string
  description = "Private IP of the Azure Firewall in the Hub to use as UDR next hop"
}

variable "use_remote_gateways" {
  type        = bool
  description = "Whether to use remote gateways from the Hub (set to true once VPN/ER gateway is deployed)"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to Spoke resources"
  default     = {}
}
