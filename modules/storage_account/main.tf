#============================================================================
# STORAGE ACCOUNT MODULE
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

variable "storage_account_name" {
  description = "Name of the Storage Account"
  type        = string
}

variable "location" {
  description = "Location where the Storage Account will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "account_tier" {
  description = "Storage Account tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage Account replication type"
  type        = string
  default     = "LRS"
}

variable "allow_blob_public_access" {
  description = "Allow public access to blobs"
  type        = bool
  default     = false
}

variable "public_network_access" {
  description = "Allow public network access to the Storage Account"
  type        = bool
  default     = false
}

variable "diagnostics_enabled" {
  description = "Enable diagnostic settings for the Storage Account"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the Storage Account"
  type        = map(string)
  default     = {}
}

#============================================================================
# RESOURCES
#============================================================================

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"
  
  # Security settings
  allow_nested_items_to_be_public = var.allow_blob_public_access
  public_network_access_enabled   = var.public_network_access
  https_traffic_only_enabled      = true
  min_tls_version                  = "TLS1_2"
  shared_access_key_enabled          = true

  # Network rules
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Storage Account diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  count                      = var.diagnostics_enabled ? 1 : 0
  name                       = "${azurerm_storage_account.main.name}-diagnostics"
  target_resource_id         = azurerm_storage_account.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }

}

#============================================================================
# OUTPUTS
#============================================================================

output "storage_account_id" {
  description = "Storage Account resource ID"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = azurerm_storage_account.main.name
}

output "primary_endpoints" {
  description = "Primary endpoints for the storage account"
  value = {
    blob  = azurerm_storage_account.main.primary_blob_endpoint
    table = azurerm_storage_account.main.primary_table_endpoint
    queue = azurerm_storage_account.main.primary_queue_endpoint
    file  = azurerm_storage_account.main.primary_file_endpoint
  }
}

output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}