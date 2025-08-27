terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  image_uri = "${var.ecr_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.repo_name}:${var.image_tag}"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.environment]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

// Security group for Lambda
resource "aws_security_group" "lambda_sg" {
  name_prefix = "${var.repo_name}-lambda-${var.environment}-"
  description = "Security group for Lambda function of ${var.repo_name} repo in ${var.environment} environment"
  vpc_id      = data.aws_vpc.main.id
  #checkov:skip=CKV2_AWS_5:Security group is attached to Lambda function via module
  #checkov:skip=CKV_AWS_382:Lambda needs a broader outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.repo_name}-lambda-${var.environment}-sg"
    Environment = var.environment
    Repo        = var.repo_name
    Terraform   = "true"
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_lambda_function" "main" {
  function_name = "${var.repo_name}-${var.environment}"
  description   = "The lambda function of ${var.repo_name} repo in ${var.environment} environment"
  image_uri     = local.image_uri
  package_type  = "Image"
  kms_key_arn   = data.aws_kms_key.this.arn
  role          = aws_iam_role.lambda.arn
  memory_size   = var.memory_size

  //checkov:skip=CKV_AWS_272:Lambda Container Image does not need to be signed
  environment {
    variables = {
      ENV = var.environment
    }
  }
  tracing_config {
    mode = "Active"
  }

  //checkov:skip=CKV_AWS_116:Lambda function should not have a dead letter queue
  //checkov:skip=CKV_AWS_115:Lambda function should not have a reserved concurrent executions

  ephemeral_storage {
    size = var.ephemeral_storage_size
  }
  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  tags = {
    Environment = var.environment
    Repo        = var.repo_name
    Terraform   = "true"
  }
  timeouts {
    create = "20m"
  }
  depends_on = [aws_cloudwatch_log_group.lambda, aws_iam_role.lambda, aws_iam_role_policy.logs, aws_iam_role_policy_attachment.lambda_vpc]

}
