data "aws_iam_policy_document" "cloudtrail_kms_policy" {
  statement {
    sid = "AllowAliasCreation"
    effect = "Allow"
    actions = [
      "kms:CreateAlias"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.cloudtrail_account_id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${var.cloudtrail_account_id}:role/Admin"
      ]
    }
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = ["ec2.${var.aws_region}.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "kms:CallerAccount"
      values = ["${var.cloudtrail_account_id}"]
    }
  }
  # This statement only allows terraform user to change this policy.
  statement {
    sid = "AllowAccessForKeyAdministrators"
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
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.cloudtrail_account_id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${var.cloudtrail_account_id}:role/Admin"
      ]
    }
  }
  statement {
    sid = "AllowCloudTrailToDescribeKey"
    effect = "Allow"
    actions = [
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
  }
  statement {
    sid = "AllowCloudTrailToEncryptLogs"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    condition {
      test = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "${formatlist("arn:aws:cloudtrail:*:%s:trail/*", var.account_id_list)}"
      ]
    }
  }
  statement {
    sid = "AllowDecryptionOfCloudTrailLogs"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.cloudtrail_account_id}:role/Admin",
        "arn:aws:iam::${var.cloudtrail_account_id}:role/Engineer",
        "arn:aws:iam::${var.cloudtrail_account_id}:role/SecurityAudit"
      ]
    }
    condition {
      test = "Null"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl"
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
    ]
  }
  statement {
    sid = "AWSCloudTrailWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    resources = [
      "${formatlist("arn:aws:s3:::%s/AWSLogs/%s/*", aws_s3_bucket.cloudtrail.id, var.account_id_list)}"
    ]
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }
  statement {
    sid = "DenyAllDelete"
    effect = "Deny"
    actions = [
      "s3:DeleteObjectVersionTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectTagging",
      "s3:DeleteObject",
      "s3:DeleteBucket"
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
    ]
  }
  statement {
    sid = "DenyPolicyUpdateOrDelete"
    effect = "Deny"
    actions = [
      "s3:PutBucketPolicy",
      "s3:GetBucketPolicy",
      "s3:DeleteBucketPolicy"
    ]
    not_principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${var.cloudtrail_account_id}:assumed-role/Admin/terraform",
        "arn:aws:iam::${var.cloudtrail_account_id}:role/Admin",
        "arn:aws:sts::${var.cloudtrail_account_id}:assumed-role/OrganizationAccountAccessRole/terraform",
        "arn:aws:iam::${var.cloudtrail_account_id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${var.cloudtrail_account_id}:root"
      ]
    }
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}"
    ]
  }
}
