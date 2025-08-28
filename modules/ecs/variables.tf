variable "region" {
  type        = string
  description = "Region to deploy the resources"
  default     = "eu-west-1"
}

variable "repo_name" {
  type        = string
  description = "Name of the repository"
}

variable "name" {
  type        = string
  description = "Name of the ECS service and related resources"
}

variable "environment" {
  type        = string
  description = "Environment (e.g. dev, stg, prod)"
}

variable "ecr_account_id" {
  type        = string
  description = "The account ID of the ECR repository"
  default     = "401853833362"
}

variable "container_image_tag" {
  type        = string
  description = "Image tag to use"
}

variable "container_port" {
  type        = number
  description = "Port exposed by the container"
  default     = 80
}

variable "task_cpu" {
  type        = number
  description = "CPU units for the task"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Memory for the task in MB"
  default     = 512
}

variable "desired_count" {
  type        = number
  description = "Number of instances of the task to run"
  default     = 1
}

variable "alb_enabled" {
  type        = bool
  description = "Whether to enable ALB"
  default     = true
}

variable "security_group_ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    description     = string
    security_groups = list(string)
  }))
  description = "List of ingress rules for ECS tasks security group"
  default = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = []
      description     = "Allow inbound traffic from ALB to ECS tasks"
      security_groups = []
    }
  ]
}

variable "security_group_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  description = "List of egress rules for ECS tasks security group"
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound traffic to the internet"
    }
  ]
}

variable "alb_security_group_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  description = "List of ingress rules for ALB security group"
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow inbound traffic from the internet to the ALB"
    }
  ]
}

variable "alb_security_group_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  description = "List of egress rules for ALB security group"
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound traffic to the internet"
    }
  ]
}

variable "deployment_circuit_breaker_enabled" {
  type        = bool
  description = "Whether to enable deployment circuit breaker"
  default     = true
}

variable "deployment_circuit_breaker_rollback" {
  type        = bool
  description = "Whether to rollback the deployment if the circuit breaker is triggered"
  default     = true
}

variable "wait_for_steady_state" {
  type        = bool
  description = "Whether to wait for the steady state of the deployment"
  default     = true
}