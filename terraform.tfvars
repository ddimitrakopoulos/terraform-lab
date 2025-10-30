#============================================================================
# TERRAFORM VARIABLES VALUES
#============================================================================
# This file contains the actual values for the Terraform variables
# Equivalent to main.bicepparam in the Bicep version

#============================================================================
# CORE DEPLOYMENT PARAMETERS
#============================================================================
resource_group_name = "rg-taskGen-dev-weu"
workload_name      = "taskgen"
location           = "westeurope"
environment        = "dev"

#============================================================================
# LOG ANALYTICS PARAMETERS
#============================================================================
log_analytics_workspace_name      = "law-taskgen-dev"
log_analytics_workspace_sku       = "PerGB2018"
log_analytics_retention_in_days   = 30
diagnostics_enabled               = true

#============================================================================
# STORAGE ACCOUNT PARAMETERS
#============================================================================
storage_account_name = "sttaskgendev"
storage_table_name   = "tabletaskgendev"

#============================================================================
# KEY VAULT PARAMETERS
#============================================================================
key_vault_name                            = "kv-taskgen-dev"
key_vault_sku                             = "standard"
key_vault_soft_delete_enabled             = true
key_vault_purge_protection_enabled        = false
key_vault_enabled_for_template_deployment = true

#============================================================================
# NETWORK PARAMETERS
#============================================================================
virtual_network_name           = "vnet-taskgen-dev"
virtual_network_address_prefix = "10.0.0.0/16"

#============================================================================
# PRIVATE ENDPOINT PARAMETERS
#============================================================================
storage_table_private_endpoint_name = "pe-taskgen-dev-table"
key_vault_private_endpoint_name      = "pe-taskgen-dev-kv"

#============================================================================
# APP SERVICE PARAMETERS
#============================================================================
app_service_name      = "app-taskgen-dev"
app_service_plan_name = "plan-taskgen-dev"
app_service_sku_name  = "B1"

#============================================================================
# SECRETS (Provide values at deployment time)
#============================================================================
# These should be provided via environment variables or secure input:
# TF_VAR_jwt_secret = "your-jwt-secret"
# TF_VAR_ddimitr_password = "your-ddimitr-password" 
# TF_VAR_hello_password = "your-hello-password"

jwt_secret       = ""
ddimitr_password = ""
hello_password   = ""