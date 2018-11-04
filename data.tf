// Create a policy for requiring MFA
// This policy is described in https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_users-self-manage-mfa-and-creds.html
data "aws_iam_policy_document" "mfa" {
  statement {
    sid = "AllowAllUsersToListAccounts"
    effect = "Allow"
    actions = [
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:GetLoginProfile",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:UpdateLoginProfile",
      "iam:ListSigningCertificates",
      "iam:DeleteSigningCertificate",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "iam:DeleteSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"
    ]
    resources = ["arn:aws:iam::${var.master_account_id}:user/$${aws:username}"]
  }

  statement {
    sid = "AllowIndividualUserToViewAndManageTheirOwnMFA"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]
    resources = [
      "arn:aws:iam::${var.master_account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${var.master_account_id}:user/$${aws:username}"
    ]
  }

  statement {
    sid = "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA"
    effect = "Allow"
    actions = [
      "iam:DeactivateMFADevice"
    ]
    resources = [
      "arn:aws:iam::${var.master_account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${var.master_account_id}:user/$${aws:username}"
    ]
  }

  statement {
    sid = "BlockMostAccessUnlessSignedInWithMFA"
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListSSHPublicKeys",
      "iam:ListAccessKeys",
      "iam:ListServiceSpecificCredentials",
      "iam:ListMFADevices",
      "iam:GetAccountSummary",
      "sts:GetSessionToken"
    ]
    not_resources = ["*"]
    condition {
      test = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values = ["false"]
    }
  }

  provider = "aws.master"
}

data "aws_iam_policy_document" "admin_group" {
  statement {
    sid = "AllowUsersToAssumeTheAdminOrReadOnlyRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/Admin",
    ]
  }
}

data "aws_iam_policy_document" "engineer_group" {
  statement {
    sid = "AllowUsersToAssumeTheEngineerRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/Engineer"
    ]
  }
}

data "aws_iam_policy_document" "security_audit_group" {
  statement {
    sid = "AllowUsersToAssumeTheSecurityAuditRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/SecurityAudit"
    ]
  }
}

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
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole",
        "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin"
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
