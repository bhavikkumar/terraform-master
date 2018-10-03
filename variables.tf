variable "prefix" {}

variable "domain_name" {}

variable "master_account_id" {}

variable "aws_default_region" {
  default = "us-east-1"
}

variable "administrator_default_arn" {
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "engineer_default_arn" {
  default = "arn:aws:iam::aws:policy/PowerUserAccess"
}

variable "billing_default_arn" {
  default = "arn:aws:iam::aws:policy/job-function/Billing"
}

variable "auditor_default_arn" {
  default = "arn:aws:iam::aws:policy/SecurityAudit"
}

variable "read_only_default_arn" {
  default = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
