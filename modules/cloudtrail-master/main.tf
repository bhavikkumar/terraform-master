// CloudTrail KMS Key
resource "aws_kms_key" "cloudtrail" {
  description = "KMS Key used by all of CloudTrail logs"
  policy = "${data.aws_iam_policy_document.cloudtrail_kms_policy.json}"
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail-key"
  target_key_id = "${aws_kms_key.cloudtrail.key_id}"
}

// CloudTrail S3 Bucket
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "cloudtrail.${var.domain_name}"
  acl = "private"

  lifecycle_rule {
    id      = "cloudtrail_lifecycle"
    enabled = true

    transition {
      days          = 730
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 1825
      storage_class = "GLACIER"
    }
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = "${aws_kms_key.cloudtrail.arn}"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "encrypt_cloudtrail_bucket" {
  bucket = "${aws_s3_bucket.cloudtrail.id}"
  policy = "${data.aws_iam_policy_document.cloudtrail_s3_policy.json}"
}
