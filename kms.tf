data "aws_iam_policy_document" "default_kms_policy" {
  statement {
    sid    = "AllowAliasCreation"
    effect = "Allow"

    actions = [
      "kms:CreateAlias",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
      ]
    }
    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "ec2.${var.aws_default_region}.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"

      values = [
        aws_organizations_account.operations.id,
      ]
    }
  }
  statement {
    sid    = "AllowAdministratorsToManageKey"
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
      "kms:UntagResource",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
      ]
    }
  }
  statement {
    sid    = "AllowAccountsAndUsersToUseKey"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
      ]
    }

    principals {
      type = "Service"
      identifiers = [
        "logs.${var.aws_default_region}.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${aws_organizations_account.operations.id}:root",
        "arn:aws:iam::${aws_organizations_account.identity.id}:root",
        "arn:aws:iam::${var.master_account_id}:root",
        "arn:aws:iam::${aws_organizations_account.development.id}:root",
        "arn:aws:iam::${aws_organizations_account.production.id}:root",
      ]
    }
  }

  statement {
    sid    = "AllowAttachmentOfPersistentResources"
    effect = "Allow"

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]

    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${aws_organizations_account.operations.id}:root",
        "arn:aws:iam::${aws_organizations_account.identity.id}:root",
        "arn:aws:iam::${var.master_account_id}:root",
        "arn:aws:iam::${aws_organizations_account.development.id}:root",
        "arn:aws:iam::${aws_organizations_account.production.id}:root",
      ]
    }
  }
}

resource "aws_kms_key" "default" {
  description = "The default KMS Key used for all services"
  policy      = data.aws_iam_policy_document.default_kms_policy.json
  tags        = merge(local.common_tags, var.tags)
  provider    = aws.operations
}

resource "aws_kms_alias" "default" {
  name          = "alias/default-key"
  target_key_id = aws_kms_key.default.key_id
  provider      = aws.operations
}

