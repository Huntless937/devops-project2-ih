# Public IP for App Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-group7"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"]
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = "waf-policy-group7"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled = true
    mode    = "Detection"
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "appgw-burgerbuilder-group7"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = ["2"]
  firewall_policy_id = azurerm_web_application_firewall_policy.main.id

  ssl_policy {
  policy_type = "Predefined"
  policy_name = "AppGwSslPolicy20220101"
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.appgw_subnet_id
  }

  # Frontend public IP
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # Frontend port 80
  frontend_port {
    name = "port-80"
    port = 80
  }

  # ─── FRONTEND BACKEND ───────────────────────────────────────
  backend_address_pool {
    name  = "pool-frontend"
    ip_addresses = [var.frontend_private_ip]
  }

  backend_http_settings {
    name                  = "http-settings-frontend"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "probe-frontend"
  }

  probe {
    name                = "probe-frontend"
    protocol            = "Http"
    host                = var.frontend_private_ip
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  # ─── BACKEND BACKEND ────────────────────────────────────────
  backend_address_pool {
    name         = "pool-backend"
    ip_addresses = [var.backend_private_ip]
  }

  backend_http_settings {
    name                  = "http-settings-backend"
    cookie_based_affinity = "Disabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "probe-backend"
  }

  probe {
    name                = "probe-backend"
    protocol            = "Http"
    host                = var.backend_private_ip
    path                = "/api/health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  # ─── LISTENER ───────────────────────────────────────────────
  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  # ─── ROUTING RULES ──────────────────────────────────────────
  # Rule 1: /api/* → backend
  url_path_map {
    name                               = "url-path-map"
    default_backend_address_pool_name  = "pool-frontend"
    default_backend_http_settings_name = "http-settings-frontend"

    path_rule {
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "pool-backend"
      backend_http_settings_name = "http-settings-backend"
      rewrite_rule_set_name      = "rewrite-api-path"
    }
  }

  request_routing_rule {
    name               = "routing-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-http"
    url_path_map_name  = "url-path-map"
    priority           = 100
  }

  rewrite_rule_set {
    name = "rewrite-api-path"

    rewrite_rule {
      name          = "strip-api-prefix"
      rule_sequence = 100

      condition {
        variable    = "var_uri_path"
        pattern     = "/api/(.*)"
        ignore_case = true
      }

      url {
        path = "/{var_uri_path_1}"
      }
    }
  }
}