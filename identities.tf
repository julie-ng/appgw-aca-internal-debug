resource "azurerm_user_assigned_identity" "app_gw" {
  name                = "app-gw-${local.suffix}-mi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.default_tags
}

resource "azurerm_user_assigned_identity" "aca_environment" {
  name                = "aca-environment-${local.suffix}-mi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.default_tags
}

resource "azurerm_user_assigned_identity" "aca_app" {
  name                = "aca-app-${local.suffix}-mi"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.default_tags
}

# ===== Role Assignments =====

# Built-in roles for Key Vault
# https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations

data "azurerm_key_vault" "jngdemos" {
  name                = "jngdemos"
  resource_group_name = "demos-shared-rg"
}


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
