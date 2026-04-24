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