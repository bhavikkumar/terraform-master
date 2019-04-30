variable "administrator_default_arn" {
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "account_id" {
  type        = "string"
  description = "The account id where the role(s) will be assumed from"
}

variable "billing_default_arn" {
  type    = "string"
  default = "arn:aws:iam::aws:policy/job-function/Billing"
}

variable "enable_read_only_for_admin" {
  default = false
}

variable "read_only_default_arn" {
  type    = "string"
  default = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}