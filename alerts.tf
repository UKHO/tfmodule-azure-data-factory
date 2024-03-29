resource "azurerm_monitor_action_group" "adf_alerts_monitor" {
    name                = "${var.org}-${var.name}-adf-alerts-monitor-${var.environment_name}"
    resource_group_name = var.resource_group_name
    short_name          = "${var.product_alias}a${var.environment_name}"
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
            name     = "Name"
            operator = "Include"
            values   = [azurerm_data_factory_pipeline.full_backup.name, azurerm_data_factory_pipeline.incremental_backup.name]
        }
    }

    action {
        action_group_id = azurerm_monitor_action_group.adf_alerts_monitor.id
    }

    lifecycle {
        ignore_changes = [tags]
    }
}