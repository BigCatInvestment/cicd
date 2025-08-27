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
