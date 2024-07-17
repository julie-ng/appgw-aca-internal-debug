# ===========
# App Gateway
# ===========

locals {
  appgw_domain_name = "appgw.int.cloudkube.io"
  kv_cert_name      = "star-int-cloudkube-io-pfx"

  aca_app_fqdn = "${azurerm_container_app.hello.name}.${azurerm_container_app_environment.env.default_domain}"

  backend_address_pool_name = "aca-hello-backend-pool"
  backend_http_setting_name = "aca-hello-backend-https-settings"
  backend_pool_fqdns = [
    local.aca_app_fqdn
  ]

  frontend_http_port_name        = "hello-frontend-http-port"
  frontend_https_port_name       = "hello-frontend-https-port"
  frontend_ip_configuration_name = "hello-frontend-ip-config"


  listener_name               = "hello-https-listener" # https
  request_routing_rule_name   = "hello-routing-rule"
  redirect_configuration_name = "hello-redirect-config"
}

# ==== Static IP ====

resource "azurerm_public_ip" "app_gw" {
  name                = "app-gateway-${local.suffix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = local.default_tags
}

data "azurerm_dns_zone" "cloudkube" {
  name                = "cloudkube.io"
  resource_group_name = "demos-shared-rg"
}

resource "azurerm_dns_a_record" "appgw_int" {
  name                = "appgw.int"
  zone_name           = data.azurerm_dns_zone.cloudkube.name
  resource_group_name = data.azurerm_dns_zone.cloudkube.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.app_gw.ip_address]
}


# ==== AppGW ====

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.default_tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.app_gw.id
    ]
  }

  ssl_certificate {
    name                = local.kv_cert_name
    key_vault_secret_id = data.azurerm_key_vault_secret.star_int.id
  }

  # ===== Subnet Config =====

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.app_gw.id
  }

  # ===== Backend Config =====

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = local.backend_pool_fqdns
  }

  backend_http_settings {
    name                  = local.backend_http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
    probe_name            = "https-healthz-probe"

    # host_name                           = local.aca_app_fqdn
    pick_host_name_from_backend_address = true # defaults to false
  }

  probe {
    name                = "https-healthz-probe"
    protocol            = "Https"
    path                = "/healthz"
    interval            = 60 # 10 min
    timeout             = 30
    unhealthy_threshold = 20 # max

    # host                                      = local.aca_app_fqdn
    pick_host_name_from_backend_http_settings = true # defaults to false
  }

  # ===== Frontend Config =====

  frontend_port {
    name = local.frontend_https_port_name
    port = 443 # ??
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gw.id
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_https_port_name
    protocol                       = "Https"
    host_name                      = local.appgw_domain_name
    ssl_certificate_name           = local.kv_cert_name
  }

  # ===== Routing Rule =====

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 2
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_setting_name
  }

  # ===== WAF =====

  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }
}
