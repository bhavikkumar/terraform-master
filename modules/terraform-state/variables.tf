variable "account_id" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
