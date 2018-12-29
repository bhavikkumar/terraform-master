variable "aws_region" {
  type = "string"
}

variable "cloudtrail_account_id" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "operations_account_id" {
  type = "string"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
