variable "administrator_default_arn" {
  default = "arn:aws:iam::aws:policy/AdministratorAccess"
}

variable "auditor_default_arn" {
  default = "arn:aws:iam::aws:policy/SecurityAudit"
}

variable "engineer_default_arn" {
  default = "arn:aws:iam::aws:policy/PowerUserAccess"
}

variable "master_account_id" {
  type = "string"
}
