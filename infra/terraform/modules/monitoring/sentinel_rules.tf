# Rule 1 — SSH Brute Force Detection
resource "azurerm_sentinel_alert_rule_scheduled" "ssh_brute_force" {
  name                       = "SSH-Brute-Force-Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "SSH Brute Force Attempt"
  description                = "Detects 5+ failed SSH login attempts from the same IP within 5 minutes"
  severity                   = "High"
  enabled                    = true
  query_frequency            = "PT5M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0

  query = <<-QUERY
    Syslog
    | where Facility == "auth" or Facility == "authpriv"
    | where SyslogMessage contains "Failed password" or SyslogMessage contains "Invalid user"
    | extend SourceIP = extract("from (\\S+)", 1, SyslogMessage)
    | extend TargetUser = extract("for (\\S+)", 1, SyslogMessage)
    | summarize FailedAttempts = count(), Users = make_set(TargetUser) by Computer, SourceIP, bin(TimeGenerated, 5m)
    | where FailedAttempts > 5
  QUERY

  incident_configuration {
    create_incident = true
    grouping {
      enabled                = true
      lookback_duration      = "PT1H"
      reopen_closed_incidents = false
      entity_matching_method = "Selected"
      group_by_entities      = ["Host"]
    }
  }

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
}

# Rule 2 — WAF SQL Injection Detection
resource "azurerm_sentinel_alert_rule_scheduled" "waf_sql_injection" {
  name                       = "WAF-SQL-Injection-Detection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "WAF Blocked SQL Injection Attempt"
  description                = "Triggers when App Gateway WAF blocks requests matching SQL injection rules"
  severity                   = "High"
  enabled                    = true
  query_frequency            = "PT5M"
  query_period               = "PT15M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0

  query = <<-QUERY
    AzureDiagnostics
    | where ResourceType == "APPLICATIONGATEWAYS"
    | where Category == "ApplicationGatewayFirewallLog"
    | where action_s == "Blocked" or isnotempty(action_s)
    | where Message contains "SQL" or ruleId_s startswith "942"
    | project TimeGenerated, clientIp_s, requestUri_s, ruleId_s, Message
    | summarize BlockedRequests = count() by clientIp_s, requestUri_s, bin(TimeGenerated, 5m)
  QUERY

  incident_configuration {
    create_incident = true
    grouping {
      enabled                = true
      lookback_duration      = "PT1H"
      reopen_closed_incidents = false
      entity_matching_method = "Selected"
      group_by_entities      = ["IP"]
    }
  }

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "clientIp_s"
    }
  }

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
}

# Rule 3 — Mass Resource Deletion
resource "azurerm_sentinel_alert_rule_scheduled" "mass_resource_deletion" {
  name                       = "Mass-Resource-Deletion"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "Mass Resource Deletion Detected"
  description                = "Multiple Azure resources deleted by same caller in short window"
  severity                   = "High"
  enabled                    = true
  query_frequency            = "PT10M"
  query_period               = "PT30M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0

  query = <<-QUERY
    AzureActivity
    | where OperationNameValue endswith "delete" or OperationNameValue endswith "DELETE"
    | where ActivityStatusValue == "Success"
    | summarize DeleteCount = count(), Resources = make_set(Resource) by Caller, bin(TimeGenerated, 10m)
    | where DeleteCount > 3
  QUERY

  incident_configuration {
    create_incident = true
    grouping {
      enabled                = true
      lookback_duration      = "PT1H"
      reopen_closed_incidents = false
      entity_matching_method = "Selected"
      group_by_entities      = ["Account"]
    }
  }

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "FullName"
      column_name = "Caller"
    }
  }

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.sentinel]
}
