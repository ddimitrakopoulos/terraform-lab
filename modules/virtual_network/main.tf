#============================================================================
# VIRTUAL NETWORK MODULE
#============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

#============================================================================
# VARIABLES
#============================================================================

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "location" {
  description = "Location where the Virtual Network will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "Tags to apply to the Virtual Network"
  type        = map(string)
  default     = {}
}

#============================================================================
# RESOURCES
#============================================================================

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnet for App Service VNet Integration
resource "azurerm_subnet" "appservice" {
  name                 = "appservice"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]


}

#============================================================================
# OUTPUTS
#============================================================================

output "vnet_id" {
  description = "Virtual Network resource ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Object containing subnet resource IDs"
  value = {
    appservice        = azurerm_subnet.appservice.id
    private_endpoints = azurerm_subnet.private_endpoints.id
  }
}

output "subnet_names" {
  description = "Object containing subnet names"
  value = {
    appservice        = azurerm_subnet.appservice.name
    private_endpoints = azurerm_subnet.private_endpoints.name
  }
}