variable "app_version" {
  type        = "string"
  description = "The version of the lambda function to deploy"
}

variable "kms_key_arn" {
  type        = "string"
  description = "The KMS Key to use for encrypting environment variables"
}

variable "log_retention_period" {
  description = "The number of days to retain the logs for in CloudWatch"
  default     = 14
}

variable "s3_bucket" {
  type        = "string"
  description = "The S3 Bucket which stores the lambda function"
}

variable "s3_folder" {
  type        = "string"
  description = "The folder which the lambda function is stored in"
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
