# Get unique AZs and select one subnet per AZ
data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

locals {
  subnet_az_map = {
    for subnet_id in data.aws_subnets.private.ids : subnet_id => data.aws_subnet.private[subnet_id].availability_zone
  }

  unique_azs = distinct(values(local.subnet_az_map))

  # Select one subnet per AZ (preferably the first one found)
  alb_subnets = [
    for az in local.unique_azs :
    [for subnet_id, subnet_az in local.subnet_az_map : subnet_id if subnet_az == az][0]
  ]
}

resource "aws_security_group" "alb" {
  count       = var.alb_enabled ? 1 : 0
  name        = "${var.name}-${var.environment}-alb-sg"
  description = "Allow inbound traffic for ALB to ECS tasks"
  vpc_id      = data.aws_vpc.main.id

  #checkov:skip=CKV_AWS_260:ALB needs a broader inbound access
  #checkov:skip=CKV2_AWS_5:Security group is attached to ALB in the same module
  # Dynamic ingress rules
  dynamic "ingress" {
    for_each = var.alb_security_group_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  # Dynamic egress rules
  dynamic "egress" {
    for_each = var.alb_security_group_egress_rules
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
    Name        = "${var.name}-${var.environment}-alb-sg"
    Repo        = local.repo_name
    Terraform   = "true"
  }
}

resource "aws_lb" "main" {
  count              = var.alb_enabled ? 1 : 0
  name               = "${var.name}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = local.alb_subnets
  //checkov:skip=CKV_AWS_150: not use deletion protection for now
  //checkov:skip=CKV_AWS_91: not use access logs for now
  //checkov:skip=CKV2_AWS_28: not use WAF for now
  drop_invalid_header_fields = true

  depends_on = [aws_security_group.alb[0]]

  tags = {
    Environment = var.environment
    Name        = "${var.name}-${var.environment}"
    Repo        = local.repo_name
    Terraform   = "true"
  }
}
