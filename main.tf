#============================================================================
# TERRAFORM CONFIGURATION
#============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

#============================================================================
# DATA SOURCES
#============================================================================

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Generate unique string for storage account naming
resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

#============================================================================
# LOCAL VALUES
#============================================================================

locals {
  common_tags = {
    workload    = var.workload_name
    environment = var.environment
    project     = "bicep-to-terraform-demo"
  }
  
  # Ensure storage account name is globally unique and follows naming rules
  storage_account_name = "${var.storage_account_name}${random_string.unique.result}"
}

#============================================================================
# LOG ANALYTICS WORKSPACE
#============================================================================

module "log_analytics_workspace" {
  source = "./modules/log_analytics_workspace"

  workspace_name      = var.log_analytics_workspace_name
  location           = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                = var.log_analytics_workspace_sku
  retention_in_days  = var.log_analytics_retention_in_days
  diagnostics_enabled = var.diagnostics_enabled
  tags               = local.common_tags
}

#============================================================================
# VIRTUAL NETWORK
#============================================================================

module "virtual_network" {
  source = "./modules/virtual_network"

  vnet_name           = var.virtual_network_name
  location           = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space      = [var.virtual_network_address_prefix]
  tags               = local.common_tags
}

#============================================================================
# STORAGE ACCOUNT
#============================================================================

module "storage_account" {
  source = "./modules/storage_account"

  storage_account_name         = local.storage_account_name
  location                    = var.location
  resource_group_name         = data.azurerm_resource_group.main.name
  allow_blob_public_access    = false
  public_network_access       = false
  diagnostics_enabled         = var.diagnostics_enabled
  log_analytics_workspace_id  = module.log_analytics_workspace.workspace_id
  tags                        = local.common_tags
}

#============================================================================
# STORAGE TABLE
#============================================================================

module "storage_table" {
  source = "./modules/storage_table"

  storage_account_name = module.storage_account.storage_account_name
  table_name          = var.storage_table_name

  depends_on = [module.storage_account]
}

#============================================================================
# KEY VAULT
#============================================================================

module "key_vault" {
  source = "./modules/key_vault"

  key_vault_name                         = var.key_vault_name
  location                              = var.location
  resource_group_name                   = data.azurerm_resource_group.main.name
  tenant_id                             = data.azurerm_client_config.current.tenant_id
  sku_name                              = var.key_vault_sku
  soft_delete_enabled                   = var.key_vault_soft_delete_enabled
  purge_protection_enabled              = var.key_vault_purge_protection_enabled
  enabled_for_template_deployment       = var.key_vault_enabled_for_template_deployment
  diagnostics_enabled                   = var.diagnostics_enabled
  log_analytics_workspace_id            = module.log_analytics_workspace.workspace_id
  tags                                  = local.common_tags
}

#============================================================================
# KEY VAULT SECRETS
#============================================================================

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwtsecret"
  value        = var.jwt_secret
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [module.key_vault]
}

resource "azurerm_key_vault_secret" "ddimitr_password" {
  name         = "ddimitrpass"
  value        = var.ddimitr_password
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [module.key_vault]
}

resource "azurerm_key_vault_secret" "hello_password" {
  name         = "hellopass"
  value        = var.hello_password
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [module.key_vault]
}

#============================================================================
# APP SERVICE
#============================================================================

module "app_service" {
  source = "./modules/app_service"

  app_service_name              = var.app_service_name
  app_service_plan_name         = var.app_service_plan_name
  app_service_plan_sku_name     = var.app_service_sku_name
  location                      = var.location
  resource_group_name           = data.azurerm_resource_group.main.name
  nodejs_version               = "20-lts"
  subnet_id                    = module.virtual_network.subnet_ids["appservice"]
  diagnostics_enabled          = var.diagnostics_enabled
  log_analytics_workspace_id   = module.log_analytics_workspace.workspace_id
  tags                         = local.common_tags

  depends_on = [
    module.key_vault,
    module.storage_account
  ]
}

#============================================================================
# PRIVATE DNS ZONES
#============================================================================

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone" "storage_table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.common_tags
}

#============================================================================
# PRIVATE DNS ZONE VIRTUAL NETWORK LINKS
#============================================================================

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "vault-vnet-link"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = module.virtual_network.vnet_id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_table" {
  name                  = "table-vnet-link"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_table.name
  virtual_network_id    = module.virtual_network.vnet_id
  registration_enabled  = false
  tags                  = local.common_tags
}

#============================================================================
# PRIVATE ENDPOINTS
#============================================================================

resource "azurerm_private_endpoint" "storage_table" {
  name                = var.storage_table_private_endpoint_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = module.virtual_network.subnet_ids["private_endpoints"]
  tags                = local.common_tags

  private_service_connection {
    name                           = "table-connection"
    private_connection_resource_id = module.storage_account.storage_account_id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "table-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_table.id]
  }
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = var.key_vault_private_endpoint_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = module.virtual_network.subnet_ids["private_endpoints"]
  tags                = local.common_tags

  private_service_connection {
    name                           = "keyvault-connection"
    private_connection_resource_id = module.key_vault.key_vault_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "vault-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }
}