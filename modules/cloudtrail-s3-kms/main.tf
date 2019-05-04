data "aws_iam_policy_document" "cloudtrail_kms_policy" {
  statement {
    sid    = "AllowAliasCreation"
    effect = "Allow"

    actions = [
      "kms:CreateAlias"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.operations_account_id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${var.operations_account_id}:role/Admin"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "ec2.${var.aws_region}.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"

      values = [
        "${var.operations_account_id}"
      ]
    }
  }

  # This statement only allows terraform user to change this policy.
  statement {
    sid    = "AllowAccessForKeyAdministrators"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.operations_account_id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${var.operations_account_id}:role/Admin"
      ]
    }
  }

  statement {
    sid    = "AllowCloudTrailToDescribeKey"
    effect = "Allow"

    actions = [
      "kms:DescribeKey"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "AllowCloudTrailToEncryptLogs"
    effect = "Allow"

    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"

      values = [
        "arn:aws:cloudtrail:*:${var.cloudtrail_account_id}:trail/*"
      ]
    }
  }

  statement {
    sid    = "AllowDecryptionOfCloudTrailLogs"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.operations_account_id}:role/Admin",
      ]
    }
    condition {
      test     = "Null"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"

      values = [
        "false"
      ]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogsToEncrypt"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "logs.${var.aws_region}.amazonaws.com"
      ]
    }
  }

}

data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/AWSLogs/*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = [
        "bucket-owner-full-control"
      ]
    }
  }

  statement {
    sid    = "DenyAllDelete"
    effect = "Deny"

    actions = [
      "s3:DeleteObjectVersionTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectTagging",
      "s3:DeleteObject",
      "s3:DeleteBucket"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "*"
      ]
    }
  }
  statement {
    sid    = "DenyPolicyUpdateOrDelete"
    effect = "Deny"

    actions = [
      "s3:PutBucketPolicy",
      "s3:GetBucketPolicy",
      "s3:DeleteBucketPolicy"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
    ]

    not_principals {
      type = "AWS"

      identifiers = [
        "arn:aws:sts::${var.operations_account_id}:assumed-role/Admin/terraform",
        "arn:aws:iam::${var.operations_account_id}:role/Admin",
        "arn:aws:sts::${var.operations_account_id}:assumed-role/OrganizationAccountAccessRole/terraform",
        "arn:aws:iam::${var.operations_account_id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${var.operations_account_id}:root"
      ]
    }
  }
}

resource "aws_kms_key" "cloudtrail" {
  description = "KMS Key used by all of CloudTrail logs"
  policy      = "${data.aws_iam_policy_document.cloudtrail_kms_policy.json}"
  tags        = "${var.tags}"
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail-key"
  target_key_id = "${aws_kms_key.cloudtrail.key_id}"
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "cloudtrail.${var.domain_name}"
  acl    = "private"

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
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "${aws_kms_key.cloudtrail.arn}"
      }
    }
  }

  tags = "${var.tags}"
}

resource "aws_s3_bucket_policy" "encrypt_cloudtrail_bucket" {
  bucket = "${aws_s3_bucket.cloudtrail.id}"
  policy = "${data.aws_iam_policy_document.cloudtrail_s3_policy.json}"
}
