output "cloudtrail_bucket_id" {
  value       = aws_s3_bucket.cloudtrail.id
  description = "CloudTrail bucket ID"
  sensitive   = true
}

output "default_kms_key_arn" {
  value       = aws_kms_key.default.arn
  description = "Default KMS Key ARN"
  sensitive   = true
}

output "log_destination_arn" {
  value       = aws_cloudwatch_log_destination.log_destination.arn
  description = "The log destination where all logs should be sent"
}

output "non_master_accounts" {
  value       = aws_organizations_organization.org.non_master_accounts
  description = "All non master accounts that are in the organization"
}

output "organization_accounts" {
  value       = aws_organizations_organization.org.accounts
  description = "All AWS accounts that are in the organization"
}

output "terraform_access_key_id" {
  value       = aws_iam_access_key.terraform.id
  description = "The Terraform User Access Key ID"
  sensitive   = true
}

output "terraform_bucket_id" {
  value       = aws_s3_bucket.terraform.id
  description = "Terraform bucket ID"
  sensitive   = true
}

output "terraform_dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state_lock.id
  description = "Terraform Lock Table Name"
  sensitive   = true
}

output "terraform_kms_key_arn" {
  value       = aws_kms_key.terraform.arn
  description = "Terraform KMS Key ARN"
  sensitive   = true
}

output "terraform_secret_access_key" {
  value       = aws_iam_access_key.terraform.secret
  description = "The Terraform User Secret Access Key"
  sensitive   = true
}

