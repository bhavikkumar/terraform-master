variable "cloudtrail_kms_key" {
  type        = "string"
  description = "The ARN of the KMS Key for CloudTrail"
}

variable "cloudtrail_name" {
  type        = "string"
  description = "The name of the trail"
  default     = "cloudtrail"
}

variable "cloudwatch_log_retention_period" {
  description = "The number of days to retain the logs for in cloudwatch"
  default     = 1
}

variable "is_organization_trail" {
  description = "Specifies whether the trail is an AWS Organizations trail."
  default     = true
}

variable "s3_bucket" {
  type        = "string"
  description = "The s3 bucket where cloudtrail logs will be stored"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
