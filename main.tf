resource "random_string" "suffix" {
  length      = 4
  numeric     = true
  special     = false
  upper       = false
  min_numeric = 2
  min_lower   = 2
}

locals {
  base_name = "appgw-aca-internal"
  location  = "eastus2"
  suffix    = random_string.suffix.result

  vnet_address_space              = ["10.0.0.0/16"]
  app_gw_address_space            = ["10.0.0.0/21"]
  aca_control_plane_address_space = ["10.0.8.0/21"]
  aca_apps_address_space          = ["10.0.16.0/21"]

  default_tags = {
    demo = "false"
    iac  = "terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.base_name}-${local.suffix}-rg"
  location = local.location
  tags     = local.default_tags
}



resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.base_name}-la-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# resource "azurerm_container_app_environment" "env" {
#   name                       = "${local.base_name}-environment"
#   location                   = azurerm_resource_group.rg.location
#   resource_group_name        = azurerm_resource_group.rg.name
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

#   infrastructure_subnet_id = azurerm_subnet.aca.id
# }


output "suffix" {
  value = random_string.suffix.result
}
