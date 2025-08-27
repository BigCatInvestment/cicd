output "sns_topic_arn" {
  value = aws_sns_topic.main.arn
}

output "integration_key" {
  value = pagerduty_service_integration.main.integration_key
}

output "service_id" {
  value = pagerduty_service.main.id
}
