# Production Landing Zone Deployment
# Deploys Hub VNet + Azure Firewall and Spokes (App Spoke & Shared Services Spoke)

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Central Connectivity Hub Module
module "hub" {
  source = "../../modules/hub_network"

  resource_group_name  = var.hub_resource_group_name
  location             = var.location
  vnet_name            = "vnet-hub-prod-${var.location}"
  address_space        = ["10.100.0.0/16"]
  gateway_subnet_cidr  = "10.100.1.0/24"
  firewall_subnet_cidr = "10.100.2.0/24"

  tags = {
    Environment = "Production"
    Role        = "Central-Hub"
    ManagedBy   = "Terraform"
    Project     = "Cloud-Migration-100"
  }
}

# 2. Workload Spoke: Core Application VNet
module "spoke_workload" {
  source = "../../modules/spoke_network"

  resource_group_name = "rg-prod-workload-${var.location}"
  location            = var.location
  vnet_name           = "vnet-spoke-workload-prod-${var.location}"
  address_space       = ["10.101.0.0/16"]
  app_subnet_cidr     = "10.101.1.0/24"
  db_subnet_cidr      = "10.101.2.0/24"
  pe_subnet_cidr      = "10.101.3.0/24"

  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_rg_name             = module.hub.hub_rg_name
  hub_firewall_private_ip = module.hub.firewall_private_ip

  tags = {
    Environment = "Production"
    Role        = "Workload-Spoke"
    ManagedBy   = "Terraform"
    Project     = "Cloud-Migration-100"
  }
}

# 3. Workload Spoke: Shared Services / CI-CD Runners VNet
module "spoke_shared" {
  source = "../../modules/spoke_network"

  resource_group_name = "rg-prod-shared-${var.location}"
  location            = var.location
  vnet_name           = "vnet-spoke-shared-prod-${var.location}"
  address_space       = ["10.102.0.0/16"]
  app_subnet_cidr     = "10.102.1.0/24"
  db_subnet_cidr      = "10.102.2.0/24"
  pe_subnet_cidr      = "10.102.3.0/24"

  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_rg_name             = module.hub.hub_rg_name
  hub_firewall_private_ip = module.hub.firewall_private_ip

  tags = {
    Environment = "Production"
    Role        = "Shared-Services"
    ManagedBy   = "Terraform"
    Project     = "Cloud-Migration-100"
  }
}
