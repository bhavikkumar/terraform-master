variable "cloudtrail_kms_key" {
  type = "string"
  description = "The ARN of the KMS Key for CloudTrail"
}

variable "cloudwatch_kms_key" {
  type = "string"
  description = "The ARN of the KMS Key for CloudWatch Logs"
}

variable "s3_bucket" {
  type = "string"
  description = "The s3 bucket where cloudtrail logs will be stored"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
