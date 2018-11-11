variable "aws_region" {
  type = "string"
}

variable "cloudtrail_account_id" {
  type = "string"
}

variable "account_id_list" {
  type = "list"
}

variable "domain_name" {
  type = "string"
}

variable "tags" {
  type = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
