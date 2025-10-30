#============================================================================
# STORAGE TABLE MODULE
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
  description = "Name of the existing Storage Account that will host the table"
  type        = string
}

variable "table_name" {
  description = "Name of the table to create"
  type        = string
}

variable "signed_identifiers" {
  description = "Table signed identifiers for access policies"
  type = list(object({
    id     = string
    start  = optional(string)
    expiry = optional(string)
    permissions = string
  }))
  default = []
}

#============================================================================
# RESOURCES
#============================================================================

resource "azurerm_storage_table" "main" {
  name                 = var.table_name
  storage_account_name = var.storage_account_name

  dynamic "acl" {
    for_each = var.signed_identifiers
    content {
      id = acl.value.id

      access_policy {
        start       = acl.value.start
        expiry      = acl.value.expiry
        permissions = acl.value.permissions
      }
    }
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