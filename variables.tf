variable "aws_default_region" {
  default = "us-east-1"
}

variable "billing_default_arn" {
  default = "arn:aws:iam::aws:policy/job-function/Billing"
}

variable "domain_name" {}

variable "master_account_id" {}

variable "prefix" {}

variable "profile" {
  default = ""
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
