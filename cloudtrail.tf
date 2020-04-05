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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "ec2.${var.aws_default_region}.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"

      values = [
        aws_organizations_account.operations.id
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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin"
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
        "arn:aws:cloudtrail:*:${var.master_account_id}:trail/*"
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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
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
        "logs.${var.aws_default_region}.amazonaws.com"
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
        "arn:aws:sts::${aws_organizations_account.operations.id}:assumed-role/Admin/terraform",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
        "arn:aws:sts::${aws_organizations_account.operations.id}:assumed-role/OrganizationAccountAccessRole/terraform",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${aws_organizations_account.operations.id}:root"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_write" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.cloudtrail.arn
    ]
  }
}

resource "aws_kms_key" "cloudtrail" {
  description = "KMS Key used by all of CloudTrail logs"
  policy      = data.aws_iam_policy_document.cloudtrail_kms_policy.json
  tags        = merge(local.common_tags, var.tags)
  provider    = aws.operations
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail-key"
  target_key_id = aws_kms_key.cloudtrail.key_id
  provider      = aws.operations
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
        kms_master_key_id = aws_kms_key.cloudtrail.arn
      }
    }
  }

  tags     = merge(local.common_tags, var.tags)
  provider = aws.operations
}

resource "aws_s3_bucket_policy" "encrypt_cloudtrail_bucket" {
  bucket   = aws_s3_bucket.cloudtrail.id
  policy   = data.aws_iam_policy_document.cloudtrail_s3_policy.json
  provider = aws.operations
}

resource "aws_iam_role" "cloudtrail" {
  name               = "CloudTrail"
  description        = "Used by CloudTrail to write logs to cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume.json
  tags               = merge(local.common_tags, var.tags)
  provider           = aws.master
}

resource "aws_iam_role_policy" "cloudwatch_write" {
  name     = "CloudwatchLogPermissions"
  role     = aws_iam_role.cloudtrail.name
  policy   = data.aws_iam_policy_document.cloudwatch_write.json
  provider = aws.master
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "CloudTrail"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.cloudtrail.arn
  tags              = merge(local.common_tags, var.tags)
  provider          = aws.master
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "CloudTrail"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  is_multi_region_trail         = true
  is_organization_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  include_global_service_events = true
  tags                          = merge(local.common_tags, var.tags)
  provider                      = aws.master
}

resource "aws_cloudwatch_log_subscription_filter" "cloudtrail_log_filter" {
  name            = "cloudtrail_log_filter"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = ""
  destination_arn = aws_cloudwatch_log_destination.log_destination.arn
  distribution    = "ByLogStream"
  provider        = aws.master
}

