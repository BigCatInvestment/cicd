data "aws_iam_policy_document" "logs" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.region}:*:log-group:/aws/lambda/${var.repo_name}-${var.environment}*"]
  }
}

data "aws_iam_policy_document" "metrics" {
  statement {
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda" {
  name        = "${var.repo_name}-lambda-${var.environment}"
  description = "The role for lambda function of ${var.repo_name} repo"
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Sid = "AllowLambdaToAssumeRole"
      }
    ]
    Version = "2012-10-17"
  })
  tags = {
    Environment = var.environment
    Repo        = var.repo_name
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy" "logs" {
  name   = "${var.repo_name}-lambda-${var.environment}-logs"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.logs.json
}

resource "aws_iam_role_policy" "metrics" {
  name   = "${var.repo_name}-lambda-${var.environment}-metrics"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.metrics.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda.id
}

resource "aws_iam_role_policy_attachment" "lambda_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.lambda.id
}
