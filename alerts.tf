resource "azurerm_monitor_action_group" "adf_alerts_monitor" {
    name = "${var.org}-${var.name}-adf-alerts-monitor-${var.environment_name}"
    resource_group_name = var.resource_group_name
    short_name = "${var.name}-adf-alerts-${var.environment_name}"

    email_receiver {
    name = "Email"
    email_address = var.alerts_email
    use_common_alert_schema = true
    }
}

resource "azurerm_monitor_metric_alert" "adf_pipeline_failure_alert" {
    name                = "adf-pipeline-failure-alert"
    provider            = azurerm.sub
    resource_group_name = var.resource_group_name
    scopes              = [ azurerm_data_factory.this.id ]

criteria {
    metric_namespace = "Microsoft.DataFactory/factories/pipelines"
    metric_name      = "FailedRuns"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
}

## You will need the action group created in your terraform

action {
    action_group_id = azurerm_monitor_action_group.adf_alerts_monitor.id
    }
}