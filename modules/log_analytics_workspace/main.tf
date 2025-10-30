#============================================================================
# LOG ANALYTICS WORKSPACE MODULE
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

variable "workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "location" {
  description = "Location where the Log Analytics workspace will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku" {
  description = "SKU for the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Number of days to retain data in the Log Analytics workspace"
  type        = number
  default     = 30
}

variable "diagnostics_enabled" {
  description = "Enable diagnostic settings for the workspace"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Log Analytics workspace"
  type        = map(string)
  default     = {}
}

#============================================================================
# RESOURCES
#============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

# Self-monitoring diagnostic settings for the workspace
resource "azurerm_monitor_diagnostic_setting" "workspace_diagnostics" {
  count                      = var.diagnostics_enabled ? 1 : 0
  name                       = "${var.workspace_name}-diagnostics"
  target_resource_id         = azurerm_log_analytics_workspace.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category_group = "audit"
  }

  metric {
    category = "AllMetrics"
  }
}

#============================================================================
# OUTPUTS
#============================================================================

output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "customer_id" {
  description = "Customer ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "primary_shared_key" {
  description = "Primary shared key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}