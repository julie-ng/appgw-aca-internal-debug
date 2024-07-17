output "aca_environment" {
  value = {
    id                = azurerm_container_app_environment.env.id
    default_domain    = azurerm_container_app_environment.env.default_domain
    static_ip_address = azurerm_container_app_environment.env.static_ip_address
  }
}

output "suffix" {
  value = random_string.suffix.result
}
