output "dynamodb_table" {
  value = aws_dynamodb_table.terraform_state_lock.id
}

output "kms_key_arn" {
  value = aws_kms_key.terraform.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.terraform.id
}
