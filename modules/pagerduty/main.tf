terraform {
  required_version = ">= 1.10"
  required_providers {
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "2.15.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "pagerduty" {
  token = var.pagerduty_api_token
}

data "pagerduty_escalation_policy" "main" {
  name = var.escalation_policy_name
}

resource "pagerduty_service" "main" {
  name                    = "${var.name}-${var.environment}"
  description             = "Service for ${var.name} in ${var.environment}"
  auto_resolve_timeout    = var.auto_resolve_timeout
  acknowledgement_timeout = var.acknowledgement_timeout
  escalation_policy       = data.pagerduty_escalation_policy.main.id
}

# Get the AWS CloudWatch vendor
data "pagerduty_vendor" "aws_cloudwatch" {
  name = "Amazon CloudWatch"
}

resource "pagerduty_service_integration" "main" {
  service = pagerduty_service.main.id
  vendor  = data.pagerduty_vendor.aws_cloudwatch.id
  name    = "${var.name}-${var.environment}-integration"
}
