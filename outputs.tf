#============================================================================
# OUTPUTS
#============================================================================

output "subnet_ids" {
  description = "Object containing all subnet resource IDs"
  value       = module.virtual_network.subnet_ids
}

output "storage_account_id" {
  description = "Storage Account resource ID"
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = module.storage_account.storage_account_name
}

output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = module.key_vault.key_vault_id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.key_vault_uri
}

output "app_service_principal_id" {
  description = "App Service managed identity principal ID"
  value       = module.app_service.app_service_principal_id
}

output "app_service_id" {
  description = "App Service resource ID"
  value       = module.app_service.app_service_id
}

output "app_service_name" {
  description = "App Service name"
  value       = module.app_service.app_service_name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  value       = module.log_analytics_workspace.workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = module.log_analytics_workspace.workspace_name
}

output "virtual_network_id" {
  description = "Virtual Network resource ID"
  value       = module.virtual_network.vnet_id
}

output "virtual_network_name" {
  description = "Virtual Network name"
  value       = module.virtual_network.vnet_name
}

output "private_dns_zones" {
  description = "Private DNS zones created"
  value = {
    key_vault     = azurerm_private_dns_zone.key_vault.name
    storage_table = azurerm_private_dns_zone.storage_table.name
  }
}

output "private_endpoints" {
  description = "Private endpoints created"
  value = {
    key_vault     = azurerm_private_endpoint.key_vault.name
    storage_table = azurerm_private_endpoint.storage_table.name
  }
}