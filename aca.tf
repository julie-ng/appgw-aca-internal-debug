# =================
#  ACA Environment
# =================

resource "azurerm_container_app_environment" "env" {
  name                       = "aca-internal-env-${local.suffix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  tags                       = local.default_tags

  infrastructure_subnet_id           = azurerm_subnet.aca_control_plane.id
  infrastructure_resource_group_name = "aca-env-${local.suffix}-managaed-rg"

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

# =====
#  App
# =====

resource "azurerm_container_app" "hello" {
  name                         = "hello-welt-${local.suffix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  template {
    max_replicas = 2
    container {
      name   = "hello-welt"
      image  = "julieio/hello:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 3000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
