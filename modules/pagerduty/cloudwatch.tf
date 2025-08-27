data "aws_kms_key" "this" {
  key_id = "alias/${var.environment}"
}

resource "aws_sns_topic_subscription" "main" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/${pagerduty_service_integration.main.integration_key}/enqueue"
}

resource "aws_sns_topic" "main" {
  name              = "${var.name}-${var.environment}-cloudwatch-alerts"
  kms_master_key_id = data.aws_kms_key.this.arn
  tags = {
    Environment = var.environment
    Name        = "${var.name}-${var.environment}-cloudwatch-alerts"
    Terraform   = "true"
  }
}
