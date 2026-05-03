# Logic App to send Telegram notifications when Sentinel incidents are created
resource "azurerm_logic_app_workflow" "telegram_alert" {
  name                = "logic-telegram-sentinel-group7"
  location            = var.location
  resource_group_name = var.resource_group_name

  parameters = {
    "$connections" = jsonencode({})
  }

  workflow_parameters = {
    "$connections" = jsonencode({
      defaultValue = {}
      type         = "Object"
    })
  }
}

resource "azurerm_logic_app_trigger_http_request" "sentinel_trigger" {
  name         = "sentinel-incident-trigger"
  logic_app_id = azurerm_logic_app_workflow.telegram_alert.id

  schema = jsonencode({
    type = "object"
    properties = {
      data = {
        type = "object"
        properties = {
          alertsCount        = { type = "integer" }
          description        = { type = "string" }
          incidentNumber     = { type = "integer" }
          incidentUrl        = { type = "string" }
          providerIncidentId = { type = "string" }
          severity           = { type = "string" }
          status             = { type = "string" }
          title              = { type = "string" }
        }
      }
    }
  })
}

resource "azurerm_logic_app_action_http" "send_telegram" {
  name         = "send-telegram-message"
  logic_app_id = azurerm_logic_app_workflow.telegram_alert.id

  method = "POST"
  uri    = "https://api.telegram.org/bot${var.telegram_bot_token}/sendMessage"

  headers = {
    "Content-Type" = "application/json"
  }

  body = jsonencode({
    chat_id    = var.telegram_chat_id
    parse_mode = "HTML"
    text       = "<b>🚨 SECURITY ALERT</b>\n\n<b>Title:</b> @{triggerBody()?['data']?['title']}\n<b>Severity:</b> @{triggerBody()?['data']?['severity']}\n<b>Status:</b> @{triggerBody()?['data']?['status']}\n<b>Description:</b> @{triggerBody()?['data']?['description']}\n<b>Incident #:</b> @{triggerBody()?['data']?['incidentNumber']}\n\n<a href=\"@{triggerBody()?['data']?['incidentUrl']}\">View in Sentinel</a>"
  })

  depends_on = [azurerm_logic_app_trigger_http_request.sentinel_trigger]
}

# Output the Logic App trigger URL so we can connect it to Sentinel
output "logic_app_trigger_url" {
  value     = azurerm_logic_app_trigger_http_request.sentinel_trigger.callback_url
  sensitive = true
}
