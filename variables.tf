#============================================================================
# CORE DEPLOYMENT VARIABLES
#============================================================================

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-taskgen-dev-weu"
}

variable "workload_name" {
  description = "Name of the workload used as naming prefix"
  type        = string
  default     = "taskgen"
}

variable "location" {
  description = "Azure region where all resources will be deployed"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment designation (dev, test, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

#============================================================================
# LOG ANALYTICS WORKSPACE VARIABLES
#============================================================================

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-taskgen-dev"
}

variable "log_analytics_workspace_sku" {
  description = "SKU for the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  
  validation {
    condition     = contains(["Free", "PerNode", "PerGB2018", "Standalone", "Standard", "Premium"], var.log_analytics_workspace_sku)
    error_message = "Invalid Log Analytics workspace SKU."
  }
}

variable "log_analytics_retention_in_days" {
  description = "Number of days to retain data in the Log Analytics workspace"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_analytics_retention_in_days >= 30 && var.log_analytics_retention_in_days <= 730
    error_message = "Retention days must be between 30 and 730."
  }
}

variable "diagnostics_enabled" {
  description = "Enable diagnostic settings for resources"
  type        = bool
  default     = true
}

#============================================================================
# STORAGE ACCOUNT VARIABLES
#============================================================================

variable "storage_account_name" {
  description = "Base name of the storage account for table storage (unique suffix will be added)"
  type        = string
  default     = "sttaskgendev"
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.storage_account_name))
    error_message = "Storage account name must be 3-20 characters long, lowercase letters and numbers only."
  }
}

variable "storage_table_name" {
  description = "Name of the storage table"
  type        = string
  default     = "tabletaskgendev"
  
  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9]{2,62}$", var.storage_table_name))
    error_message = "Table name must start with a letter and be 3-63 characters long."
  }
}

#============================================================================
# KEY VAULT VARIABLES
#============================================================================

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-taskgen-dev"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "Key Vault name must be 3-24 characters, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "key_vault_sku" {
  description = "SKU name for the Key Vault"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "key_vault_soft_delete_enabled" {
  description = "Enable soft delete functionality for Key Vault"
  type        = bool
  default     = true
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_enabled_for_template_deployment" {
  description = "Enable Azure Resource Manager template deployment access to Key Vault"
  type        = bool
  default     = true
}

#============================================================================
# NETWORK VARIABLES
#============================================================================

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-taskgen-dev"
}

variable "virtual_network_address_prefix" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.virtual_network_address_prefix, 0))
    error_message = "Virtual network address prefix must be a valid CIDR block."
  }
}

#============================================================================
# PRIVATE ENDPOINT VARIABLES
#============================================================================

variable "storage_table_private_endpoint_name" {
  description = "Name of the private endpoint for storage table"
  type        = string
  default     = "pe-taskgen-dev-table"
}

variable "key_vault_private_endpoint_name" {
  description = "Name of the private endpoint for Key Vault"
  type        = string
  default     = "pe-taskgen-dev-kv"
}

#============================================================================
# APP SERVICE VARIABLES
#============================================================================

variable "app_service_name" {
  description = "Name of the App Service web application"
  type        = string
  default     = "app-taskgen-dev"
}

variable "app_service_plan_name" {
  description = "Name of the App Service hosting plan"
  type        = string
  default     = "plan-taskgen-dev"
}

variable "app_service_sku_name" {
  description = "SKU name for the App Service hosting plan"
  type        = string
  default     = "B1"
  
  validation {
    condition = contains([
      "F1", "D1", "B1", "B2", "B3", "S1", "S2", "S3", 
      "P1v2", "P2v2", "P3v2", "P1v3", "P2v3", "P3v3"
    ], var.app_service_sku_name)
    error_message = "Invalid App Service SKU name."
  }
}

#============================================================================
# SECRET VARIABLES
#============================================================================

variable "jwt_secret" {
  description = "JWT secret for application authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ddimitr_password" {
  description = "Password for ddimitr user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "hello_password" {
  description = "Password for hello user"
  type        = string
  sensitive   = true
  default     = ""
}