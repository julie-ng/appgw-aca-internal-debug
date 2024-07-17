output "aca_environment" {
  value = {
    id                = azurerm_container_app_environment.env.id
    default_domain    = azurerm_container_app_environment.env.default_domain
    static_ip_address = azurerm_container_app_environment.env.static_ip_address
  }
}

output "aca_app" {
  value = {
    name                         = azurerm_container_app.hello.name
    fqdn                         = "${azurerm_container_app.hello.name}.${azurerm_container_app_environment.env.default_domain}"
    workload_profile_name        = azurerm_container_app.hello.workload_profile_name
    latest_revision_name         = azurerm_container_app.hello.latest_revision_name
    container_app_environment_id = azurerm_container_app.hello.container_app_environment_id
  }
}

output "private_dns_zone" {
  value = {
    name                  = azurerm_private_dns_zone.aca_env.name
    resource_group_name   = azurerm_private_dns_zone.aca_env.resource_group_name
    number_of_record_sets = azurerm_private_dns_zone.aca_env.number_of_record_sets
  }
}

output "suffix" {
  value = random_string.suffix.result
}

output "app_gateway" {
  value = {
    id       = azurerm_application_gateway.appgw.id
    identity = azurerm_application_gateway.appgw.identity

    backend_address_pool  = azurerm_application_gateway.appgw.backend_address_pool
    backend_http_settings = azurerm_application_gateway.appgw.backend_http_settings

    frontend_port             = azurerm_application_gateway.appgw.frontend_port
    frontend_ip_configuration = azurerm_application_gateway.appgw.frontend_ip_configuration

    http_listener        = azurerm_application_gateway.appgw.http_listener
    request_routing_rule = azurerm_application_gateway.appgw.request_routing_rule
  }
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "app_gw_static_pip" {
  value = azurerm_public_ip.app_gw.ip_address
}
