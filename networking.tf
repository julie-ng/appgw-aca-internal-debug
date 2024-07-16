
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.base_name}-${local.suffix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = local.vnet_address_space
  tags                = local.default_tags
}

resource "azurerm_subnet" "app_gw" {
  name                 = "app-gw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = local.app_gw_address_space
}

resource "azurerm_subnet" "aca_apps" {
  name                 = "aca-apps-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = local.aca_apps_address_space

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "aca_control_plane" {
  name                 = "aca-control-plane-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = local.aca_control_plane_address_space

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}


# ===========
# App Gateway
# ===========

# ===== Static IP =====

resource "azurerm_public_ip" "app_gw" {
  name                = "app-gateway-${local.suffix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = local.default_tags
}


