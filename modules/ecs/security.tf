# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name}-${var.environment}-sg"
  description = "Allow inbound traffic for ECS tasks from ALB"
  vpc_id      = data.aws_vpc.main.id

  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = var.security_group_ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  # Dynamic egress rules
  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {
    Environment = var.environment
    Name        = "${var.name}-${var.environment}-sg"
    Repo        = local.repo_name
    Terraform   = "true"
  }
}
