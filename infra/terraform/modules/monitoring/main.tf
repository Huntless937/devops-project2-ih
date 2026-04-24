# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-burgerbuilder-group7"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insights for Frontend
resource "azurerm_application_insights" "frontend" {
  name                = "appi-frontend-group7"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
}

# Application Insights for Backend
resource "azurerm_application_insights" "backend" {
  name                = "appi-backend-group7"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
}

# Action Group (where alerts get sent — your email)
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-burgerbuilder"
  resource_group_name = var.resource_group_name
  short_name          = "burgerbuild"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }
}

# Alert 1 — App Gateway backend health < 100%
resource "azurerm_monitor_metric_alert" "appgw_backend_health" {
  name                = "alert-appgw-backend-health"
  resource_group_name = var.resource_group_name
  scopes              = [var.appgw_id]
  description         = "App Gateway backend health dropped below 100%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Alert 2 — VM CPU > 70%
resource "azurerm_monitor_metric_alert" "vm_cpu" {
  name                = "alert-vm-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.frontend_vm_id, var.backend_vm_id]
  description         = "VM CPU usage exceeded 70%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Alert 3 — SQL DTU > 80%
resource "azurerm_monitor_metric_alert" "sql_dtu" {
  name                = "alert-sql-dtu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "SQL Database DTU consumption exceeded 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}