data "aws_iam_policy_document" "terraform_kms_policy" {
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
    sid = "AllowUsersAndTerraformToUseTheKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Engineer"
      ]
    }
  }
}
