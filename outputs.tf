output "aca_environment" {
  value = {
    id                = azurerm_container_app_environment.env.id
    default_domain    = azurerm_container_app_environment.env.default_domain
    static_ip_address = azurerm_container_app_environment.env.static_ip_address
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
