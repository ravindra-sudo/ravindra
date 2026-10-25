variable "resource_group_name" {
  type        = string
  description = "The name of the Hub resource group"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"
  default     = "eastus"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Hub Virtual Network"
  default     = "vnet-hub-prod"
}

variable "address_space" {
  type        = list(string)
  description = "CIDR address space for the Hub VNet"
  default     = ["10.100.0.0/16"]
}

variable "gateway_subnet_cidr" {
  type        = string
  description = "CIDR block for GatewaySubnet (minimum /27, recommended /24)"
  default     = "10.100.1.0/24"
}

variable "firewall_subnet_cidr" {
  type        = string
  description = "CIDR block for AzureFirewallSubnet (minimum /26)"
  default     = "10.100.2.0/24"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to all Hub resources"
  default = {
    Environment  = "Platform-Hub"
    ManagedBy    = "Terraform"
    Architecture = "Hub-and-Spoke"
  }
}
