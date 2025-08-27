variable "pagerduty_api_token" {
  type        = string
  description = "The API token for PagerDuty"
}

variable "region" {
  type        = string
  description = "The region to deploy the resources"
  default     = "eu-west-1"
}

variable "name" {
  type        = string
  description = "The name of the service"
}

variable "environment" {
  type        = string
  description = "The environment of the service"
}

variable "escalation_policy_name" {
  type        = string
  description = "The name of the escalation policy"
}

variable "auto_resolve_timeout" {
  type        = number
  description = "The auto resolve timeout in seconds"
  default     = 14400
}

variable "acknowledgement_timeout" {
  type        = number
  description = "The acknowledgement timeout in seconds"
  default     = 600
}
