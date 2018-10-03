output "master_account_alias" {
  value = "${aws_iam_account_alias.master.account_alias}"
}

output "operations_account_id" {
  value = "${aws_organizations_account.operations.id}"
}

output "operations_account_alias" {
  value = "${aws_iam_account_alias.operations.account_alias}"
}

output "cloudtrail_bucket_id" {
  value       = "${aws_s3_bucket.cloudtrail.id}"
  description = "CloudTrail bucket ID"
}

output "terraform_bucket_id" {
  value       = "${aws_s3_bucket.terraform.id}"
  description = "Terraform bucket ID"
}

output "terraform_kms_key_arn" {
  value = "${aws_kms_key.terraform.arn}"
  description = "Terraform KMS Key ARN"
}

output "terraform_dynamodb_table_arn" {
  value = "${aws_dynamodb_table.terraform_state_lock.arn}"
  description = "Terraform Lock Table ARN"
}

output "terraform_dynamodb_table_name" {
  value = "${aws_dynamodb_table.terraform_state_lock.id}"
  description = "Terraform Lock Table Name"
}
