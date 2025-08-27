# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/ecs/${var.name}-${var.environment}"
  retention_in_days = 365
  kms_key_id        = data.aws_kms_key.this.arn

  tags = {
    Environment = var.environment
    Name        = "${var.name}-${var.environment}-logs"
    Repo        = local.repo_name
    Terraform   = "true"
  }
}
