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
  repo_name = var.repo_name
  image_uri = "${var.ecr_account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.repo_name}:${var.container_image_tag}"

  container_definition = {
    name      = "${var.name}-${var.environment}"
    image     = local.image_uri
    essential = true

    portMappings = [
      {
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.main.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-${var.environment}"

  setting {

    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.name}-${var.environment}"
    Repo        = local.repo_name
    Terraform   = "true"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([local.container_definition])

  depends_on = [aws_cloudwatch_log_group.main, aws_iam_role.ecs_execution_role, aws_iam_role.ecs_task_role]

  tags = {
    Environment = var.environment
    Name        = "${var.name}-${var.environment}"
    Repo        = local.repo_name
    Terraform   = "true"
  }
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
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.name}-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  wait_for_steady_state = true

  depends_on = [aws_cloudwatch_log_group.main, aws_ecs_cluster.main, aws_ecs_task_definition.main,
  aws_security_group.ecs_tasks]

  tags = {
    Environment = var.environment
    Name        = "${var.name}-${var.environment}"
    Repo        = local.repo_name
    Terraform   = "true"
  }
}

data "aws_kms_key" "this" {
  key_id = "alias/${var.environment}"
}
