data "aws_kms_key" "this" {
  key_id = "alias/${var.environment}"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.repo_name}-${var.environment}"
  retention_in_days = 365
  kms_key_id        = data.aws_kms_key.this.arn

  tags = {
    Environment = var.environment
    Repo        = var.repo_name
    Terraform   = "true"
  }
}
