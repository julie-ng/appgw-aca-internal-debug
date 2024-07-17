data "azurerm_key_vault" "jngdemos" {
  name                = "jngdemos"
  resource_group_name = "demos-shared-rg"
}

# ==== Key Vault References ====

# data "azurerm_key_vault_certificate" "star_int" {
#   name         = local.kv_cert_name
#   key_vault_id = data.azurerm_key_vault.jngdemos.id
# }

data "azurerm_key_vault_secret" "star_int" {
  name         = local.kv_cert_name
  key_vault_id = data.azurerm_key_vault.jngdemos.id
}

# ===== Role Assignments =====

# Built-in roles for Key Vault
# https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations

resource "azurerm_role_assignment" "appgw_on_keyvault" {
  scope                = data.azurerm_key_vault.jngdemos.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_user_assigned_identity.app_gw.principal_id
}

resource "azurerm_role_assignment" "aca_env_on_keyvault" {
  scope                = data.azurerm_key_vault.jngdemos.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_user_assigned_identity.aca_environment.principal_id
}

resource "azurerm_role_assignment" "aca_app_on_keyvault" {
  scope                = data.azurerm_key_vault.jngdemos.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_user_assigned_identity.aca_app.principal_id
}
