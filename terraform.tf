data "aws_iam_policy_document" "terraform_kms_policy" {
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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole"
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
    sid    = "AllowUsersAndTerraformToUseTheKey"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Terraform",
      ]
    }
  }
}

data "aws_iam_policy_document" "terraform_s3_policy" {
  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.terraform.id}/*"
    ]

    principals {
      type = "*"

      identifiers = [
        "*"
      ]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "aws:kms"
      ]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.terraform.id}/*"
    ]

    principals {
      type = "*"

      identifiers = [
        "*"
      ]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true"
      ]
    }
  }

  statement {
    sid    = "DenyDeleteBucket"
    effect = "Deny"

    actions = [
      "s3:DeleteBucket"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.terraform.id}"
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
      "s3:DeleteBucketPolicy"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.terraform.id}"
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

resource "aws_kms_key" "terraform" {
  description = "KMS Key used by Terraform"
  policy      = data.aws_iam_policy_document.terraform_kms_policy.json
  tags        = merge(local.common_tags, var.tags)
  provider    = aws.operations
}

resource "aws_kms_alias" "terraform" {
  name          = "alias/terraform-key"
  target_key_id = aws_kms_key.terraform.key_id
  provider      = aws.operations
}

resource "aws_s3_bucket" "terraform" {
  bucket = "terraform.${var.domain_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.terraform.arn
      }
    }
  }

  tags     = merge(local.common_tags, var.tags)
  provider = aws.operations
}

resource "aws_s3_bucket_policy" "encrypt_terraform_bucket" {
  bucket   = aws_s3_bucket.terraform.id
  policy   = data.aws_iam_policy_document.terraform_s3_policy.json
  provider = aws.operations
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags     = merge(local.common_tags, var.tags)
  provider = aws.operations
}