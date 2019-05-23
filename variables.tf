variable "aws_default_region" {
  type    = string
  default = "us-east-1"
}

variable "domain_name" {
  type = string
}

variable "master_account_id" {
  type = string
}

variable "prefix" {
  type = string
}

variable "profile" {
  type    = string
  default = "default"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

