output "kms_key_arn" {
  value = aws_kms_key.cloudtrail.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.cloudtrail.id
}
