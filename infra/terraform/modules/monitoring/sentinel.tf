# Enable Microsoft Sentinel on existing Log Analytics Workspace
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.main.id
}

# Data Connector — Azure Active Directory
resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
  name                       = "AzureActiveDirectory"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
}
