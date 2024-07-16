resource "azurerm_container_app_environment" "env" {
  name                       = "aca-env-${local.suffix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  tags                       = local.default_tags

  infrastructure_resource_group_name = "aca-env-${local.suffix}-managaed-rg"
  infrastructure_subnet_id           = azurerm_subnet.aca_control_plane.id

  internal_load_balancer_enabled = true # internal environment

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    minimum_count         = 0
    maximum_count         = 0
  }

  workload_profile {
    name                  = "Dedicated"
    workload_profile_type = "D4"
    minimum_count         = 1
    maximum_count         = 3
  }
}

# ===== Outputs =====

output "aca_environment" {
  value = {
    id                = azurerm_container_app_environment.env.id
    default_domain    = azurerm_container_app_environment.env.default_domain
    static_ip_address = azurerm_container_app_environment.env.static_ip_address
  }
}
