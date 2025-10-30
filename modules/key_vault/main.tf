#============================================================================
# KEY VAULT MODULE
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

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "location" {
  description = "Location where the Key Vault will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Key Vault"
  type        = string
  default     = "standard"
}

variable "soft_delete_enabled" {
  description = "Enable soft delete functionality for Key Vault"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Enable Azure Resource Manager template deployment access to Key Vault"
  type        = bool
  default     = false
}

variable "diagnostics_enabled" {
  description = "Enable diagnostic settings for Key Vault"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the Key Vault"
  type        = map(string)
  default     = {}
}

#============================================================================
# RESOURCES
#============================================================================

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = var.sku_name
  soft_delete_retention_days  = 90
  purge_protection_enabled    = var.purge_protection_enabled
  enable_rbac_authorization   = true
  enabled_for_template_deployment = var.enabled_for_template_deployment

  # Network settings
  public_network_access_enabled = false
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Key Vault diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "key_vault_diagnostics" {
  count                      = var.diagnostics_enabled ? 1 : 0
  name                       = "${azurerm_key_vault.main.name}-diagnostics"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
  }
}

#============================================================================
# OUTPUTS
#============================================================================

output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}