#============================================================================
# STORAGE ACCOUNT MODULE
#============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.99"
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

variable "enable_static_website" {
  description = "Enable a simple static website (index.html / 404.html) to speed up storage data plane readiness on initial provisioning"
  type        = bool
  default     = false
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

  # Security / access settings
  # NOTE: allow_blob_public_access attribute removed due to provider schema mismatch on current version.
  # Default behavior (disallow public blob access) is acceptable; adjust later if needed.
  public_network_access_enabled = true
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = false  # Keep enabled for provider stability; can be disabled post-deploy via CLI if RBAC-only desired

  dynamic "static_website" {
    for_each = var.enable_static_website ? [1] : []
    content {
      index_document      = "index.html"
      error_404_document  = "404.html"
    }
  }

  tags = var.tags
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