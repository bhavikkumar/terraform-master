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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole"
      ]
    }
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "kms:ViaService"
      values = ["ec2.${var.aws_default_region}.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "kms:CallerAccount"
      values = ["${aws_organizations_account.operations.id}"]
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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole"
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
        "arn:aws:cloudtrail:*:${var.master_account_id}:trail/*",
        "arn:aws:cloudtrail:*:${aws_organizations_account.operations.id}:trail/*"
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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Engineer"
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
