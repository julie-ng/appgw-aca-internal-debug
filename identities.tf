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

