variable "master_account_id" {}

variable "administrator_default_arn" {
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "engineer_default_arn" {
  default = "arn:aws:iam::aws:policy/PowerUserAccess"
}

variable "auditor_default_arn" {
  default = "arn:aws:iam::aws:policy/SecurityAudit"
}
