resource "azurerm_monitor_action_group" "adf_alerts_monitor" {
    name                = "${var.org}-${var.name}-adf-alerts-monitor-${var.environment_name}"
    resource_group_name = var.resource_group_name
    short_name          = "${var.name}alerts${var.environment_name}"
    provider            = azurerm.sub

    email_receiver {
        name                    = "Email-Alert"
        email_address           = var.alert_email_address
        use_common_alert_schema = true
    }
    lifecycle {
        ignore_changes = [tags]
    }
}

resource "azurerm_monitor_metric_alert" "adf_pipeline_failure_alert" {
    name                = "adf-pipeline-failure-alert"
    provider            = azurerm.sub
    resource_group_name = var.resource_group_name
    scopes              = [ azurerm_data_factory.this.id ]

    criteria {
        metric_namespace = "Microsoft.DataFactory/factories"
        metric_name      = "PipelineFailedRuns"
        aggregation      = "Total"
        operator         = "GreaterThan"
        threshold        = 0
        dimension {
            name     = "PipelineName"
            operator = "Include"
            values   = ["${var.environment_name}DataLakeBackupFull", "${var.environment_name}DataLakeBackupIncremental"]
        }
    }

    action {
        action_group_id = azurerm_monitor_action_group.adf_alerts_monitor.id
    }

    lifecycle {
        ignore_changes = [tags]
    }
}

resource "azurerm_monitor_metric_alert" "adf_pipeline_success_alert" {
    name                = "adf-pipeline-success-alert"
    provider            = azurerm.sub
    resource_group_name = var.resource_group_name
    scopes              = [ azurerm_data_factory.this.id ]

    criteria {
        metric_namespace = "Microsoft.DataFactory/factories"
        metric_name      = "PipelineSucceededRuns"
        aggregation      = "Total"
        operator         = "GreaterThan"
        threshold        = 0
        dimension {
            name     = "PipelineName"
            operator = "Include"
            values   = ["${var.environment_name}DataLakeBackupFull", "${var.environment_name}DataLakeBackupIncremental"]
        }
}

action {
        action_group_id = azurerm_monitor_action_group.adf_alerts_monitor.id
    }

    lifecycle {
        ignore_changes = [tags]
    }
}