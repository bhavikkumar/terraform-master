output "master_account_alias" {
  value = "${aws_iam_account_alias.master.account_alias}"
  sensitive = true
}

output "operations_account_id" {
  value = "${aws_organizations_account.operations.id}"
  sensitive = true
}

output "operations_account_alias" {
  value = "${aws_iam_account_alias.operations.account_alias}"
  sensitive = true
}

output "cloudtrail_bucket_id" {
  value       = "${module.cloudtrail.s3_bucket}"
  description = "CloudTrail bucket ID"
  sensitive = true
}

output "terraform_bucket_id" {
  value       = "${module.terraform.s3_bucket}"
  description = "Terraform bucket ID"
}

output "terraform_kms_key_arn" {
  value = "${module.terraform.kms_key_arn}"
  description = "Terraform KMS Key ARN"
  sensitive = true
}

output "terraform_dynamodb_table_name" {
  value = "${module.terraform.dynamodb_table}"
  description = "Terraform Lock Table Name"
}
