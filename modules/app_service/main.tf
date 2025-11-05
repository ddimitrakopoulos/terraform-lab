#============================================================================
# APP SERVICE MODULE
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

variable "app_service_name" {
  description = "Name of the App Service web application"
  type        = string
}

variable "app_service_plan_name" {
  description = "Name of the App Service hosting plan"
  type        = string
}

variable "location" {
  description = "Location where the App Service resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "app_service_plan_sku_name" {
  description = "SKU for the App Service hosting plan"
  type        = string
  default     = "B1"
}

variable "nodejs_version" {
  description = "Node.js runtime version for the App Service"
  type        = string
  default     = "20-lts"
}

variable "subnet_id" {
  description = "Subnet resource ID for VNet integration"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the App Service resources"
  type        = map(string)
  default     = {}
}

#============================================================================
# RESOURCES
#============================================================================

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku_name
  tags                = var.tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = var.nodejs_version
    }

    app_command_line = ""
    always_on = var.app_service_plan_sku_name == "F1" ? false : true
    ftps_state = "Disabled"
    minimum_tls_version = "1.2"
    use_32_bit_worker = true
    load_balancing_mode = "LeastRequests"
    
    vnet_route_all_enabled = var.app_service_plan_sku_name != "F1" ? true : false
  }

  app_settings = {
    "PORT"          = "8080"
    "WEBSITES_PORT" = "8080"
    "NODE_ENV"      = "production"
    "WEBSITE_DNS_SERVER"      = "168.63.129.16"
  }

  # VNet integration (only if not F1)
  virtual_network_subnet_id = var.app_service_plan_sku_name != "F1" ? var.subnet_id : null
}

#============================================================================
# OUTPUTS
#============================================================================

output "app_service_id" {
  description = "App Service resource ID"
  value       = azurerm_linux_web_app.main.id
}

output "app_service_name" {
  description = "App Service name"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_plan_id" {
  description = "App Service Plan resource ID"
  value       = azurerm_service_plan.main.id
}

output "app_service_principal_id" {
  description = "App Service managed identity principal ID"
  value       = azurerm_linux_web_app.main.identity[0].principal_id
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.main.default_hostname
}