# SNS topic hub messagerie
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts-${var.environment}"
  tags = {
  project  = var.project_name
  Environnement = var.environment
}
}

# Subscription pour recevoir les alertes par email
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}


# CloudWatch Alarm pour surveiller le drift du modèle

resource "aws_cloudwatch_metric_alarm" "drift_alarm" {
  alarm_name          = "${var.project_name}-drift-${var.environment}"
  alarm_description   = "Data drift détecté sur ${var.sagemaker_endpoint_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "feature_baseline_drift_distance"
  namespace           = "aws/sagemaker/Endpoints/data-metrics"
  period              = 3600
  statistic           = "Average"
  threshold           = var.drift_threshold

  dimensions = {
    Endpoint           = var.sagemaker_endpoint_name
    MonitoringSchedule = "${var.sagemaker_endpoint_name}-monitor"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# CloudWatch Dashboard pour visualiser les métriques de l'endpoint SageMaker

resource "aws_cloudwatch_dashboard" "ml_monitoring" {
  dashboard_name = "${var.project_name}-dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Endpoint Invocations"
          region  = "eu-west-3"        # ← manquait
          period  = 300
          stat    = "Sum"              # ← manquait
          view    = "timeSeries"       # ← manquait
          metrics = [["AWS/SageMaker", "Invocations",
            "EndpointName", var.sagemaker_endpoint_name]]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Latence modèle (ms)"
          region  = "eu-west-3"
          period  = 300
          stat    = "Average"
          view    = "timeSeries"
          metrics = [["AWS/SageMaker", "ModelLatency",
            "EndpointName", var.sagemaker_endpoint_name]]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title   = "Data Drift Distance"
          region  = "eu-west-3"
          period  = 3600
          stat    = "Average"
          view    = "timeSeries"
          metrics = [["aws/sagemaker/Endpoints/data-metrics",
            "feature_baseline_drift_distance",
            "Endpoint", var.sagemaker_endpoint_name]]
        }
      }
    ]
  })
}

