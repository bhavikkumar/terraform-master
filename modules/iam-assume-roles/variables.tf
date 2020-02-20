variable "account_id" {
  type        = string
  description = "The account id where the role(s) will be assumed from"
}

variable "administrator_default_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
  description = "The ARN of the policy to assign the admin role"
}

variable "billing_default_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/job-function/Billing"
  description = "The ARN of the policy to assign for billing privileges"
}

variable "enable_read_only_for_admin" {
  default     = false
  description = "Toggles admin role to only allow read only access"
}

variable "read_only_default_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  description = "The ARN of the policy to assign for read only privileges"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "terraform_default_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
  description = "The ARN of the policy to assign the terraform role"
}
