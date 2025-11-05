#============================================================================
# STORAGE TABLE MODULE
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
  description = "Name of the existing Storage Account that will host the table"
  type        = string
}

variable "table_name" {
  description = "Name of the table to create"
  type        = string
}

#============================================================================
# RESOURCES
#============================================================================

resource "azurerm_storage_table" "main" {
  name                 = var.table_name
  storage_account_name = var.storage_account_name

  lifecycle {
    ignore_changes = [acl]
  }
}

#============================================================================
# OUTPUTS
#============================================================================

output "table_name" {
  description = "Name of the created table"
  value       = azurerm_storage_table.main.name
}

output "table_id" {
  description = "Resource ID of the table"
  value       = azurerm_storage_table.main.id
}