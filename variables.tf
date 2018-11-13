variable "aws_default_region" {
  type    = "string"
  default = "us-east-1"
}

variable "billing_default_arn" {
  type    = "string"
  default = "arn:aws:iam::aws:policy/job-function/Billing"
}

variable "domain_name" {
  type = "string"
}

variable "iam_admin_arn" {
  type    = "string"
  default = "arn:aws:iam::aws:policy/IAMFullAccess"
}

variable "master_account_id" {
  type = "string"
}

variable "prefix" {
  type = "string"
}

variable "profile" {
  type    = "string"
  default = "default"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
