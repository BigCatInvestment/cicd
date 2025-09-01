variable "region" {
  type        = string
  description = "The region to deploy the resources"
  default     = "eu-west-1"
}

variable "environment" {
  type        = string
  description = "The environment (e.g. dev, stg, prod)"
}

variable "repo_name" {
  type        = string
  description = "The name of the repository"
}

variable "ecr_account_id" {
  type        = string
  description = "The account ID of the ECR repository"
  default     = "401853833362"
}

variable "image_tag" {
  type        = string
  description = "The tag of the image"
}

variable "memory_size" {
  type        = number
  description = "The memory size of the lambda function"
  default     = 128
}

variable "ephemeral_storage_size" {
  type        = number
  description = "The size of the ephemeral storage"
  default     = 512
}

variable "enable_secrets_manager" {
  description = "Whether to enable Secrets Manager access for the Lambda function"
  type        = bool
  default     = false
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs that the Lambda function can access"
  type        = list(string)
  default     = []
}

variable "subnet_type" {
  description = "Type of subnets to use for Lambda VPC configuration. Options: 'private', 'public', or 'none' to disable VPC"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public", "none"], var.subnet_type)
    error_message = "subnet_type must be one of: private, public, none"
  }
}

variable "enable_vpc" {
  description = "Whether to enable VPC configuration for the Lambda function"
  type        = bool
  default     = true
}
