variable "location" {
  type        = string
  description = "Target Azure Region for the Production Landing Zone"
  default     = "eastus"
}

variable "hub_resource_group_name" {
  type        = string
  description = "Resource Group Name for the Central Hub"
  default     = "rg-hub-prod-eastus"
}
