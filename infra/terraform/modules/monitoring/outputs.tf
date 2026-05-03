output "frontend_instrumentation_key" {
  value     = azurerm_application_insights.frontend.instrumentation_key
  sensitive = true
}

output "backend_instrumentation_key" {
  value     = azurerm_application_insights.backend.instrumentation_key
  sensitive = true
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "logic_app_trigger_url" {
  value     = azurerm_logic_app_trigger_http_request.sentinel_trigger.callback_url
  sensitive = true
}
