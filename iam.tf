// Create a policy for requiring MFA
// This policy is described in https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_users-self-manage-mfa-and-creds.html
data "aws_iam_policy_document" "mfa" {
  statement {
    sid    = "AllowAllUsersToListAccounts"
    effect = "Allow"

    actions = [
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"
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

    resources = [
      "arn:aws:iam::${aws_organizations_account.identity.id}:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToViewAndManageTheirOwnMFA"
    effect = "Allow"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]

    resources = [
      "arn:aws:iam::${aws_organizations_account.identity.id}:mfa/$${aws:username}",
      "arn:aws:iam::${aws_organizations_account.identity.id}:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA"
    effect = "Allow"

    actions = [
      "iam:DeactivateMFADevice"
    ]

    resources = [
      "arn:aws:iam::${aws_organizations_account.identity.id}:mfa/$${aws:username}",
      "arn:aws:iam::${aws_organizations_account.identity.id}:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "BlockMostAccessUnlessSignedInWithMFA"
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
      "sts:GetSessionToken",
      "iam:CreateLoginProfile"
    ]

    not_resources = [
      "*"
    ]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "assume_admin" {
  statement {
    sid    = "AllowUsersToAssumeTheAdminRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "arn:aws:iam::*:role/Admin",
    ]
  }
}

data "aws_iam_policy_document" "assume_terraform" {
  statement {
    sid    = "AllowTerraformToAssumeTerraformRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "arn:aws:iam::*:role/Terraform",
    ]
  }
}

data "aws_iam_policy_document" "manage_users" {
  statement {
    sid    = "AllowAdminsToManageUsers"
    effect = "Allow"

    actions = [
      "iam:AddUserToGroup",
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:CreateUser",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:DeleteSSHPublicKey",
      "iam:DeleteUser",
      "iam:DeleteVirtualMFADevice",
      "iam:RemoveUserFromGroup",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = true
  max_password_age               = 0
  provider                       = "aws.identity"
}

resource "aws_iam_policy" "mfa_policy" {
  name        = "EnforceMFA"
  path        = "/"
  description = "Policy which enforces MFA while allowing users to manage MFA devices"
  policy      = "${data.aws_iam_policy_document.mfa.json}"
  provider    = "aws.identity"
}

resource "aws_iam_group" "admin" {
  name     = "Admin"
  provider = "aws.identity"
}

resource "aws_iam_group_policy" "admin_assume_role" {
  name     = "admin-assume-role"
  group    = "${aws_iam_group.admin.id}"
  policy   = "${data.aws_iam_policy_document.assume_admin.json}"
  provider = "aws.identity"
}

resource "aws_iam_group_policy" "manage_users" {
  name     = "admin-can-manager-users"
  group    = "${aws_iam_group.admin.id}"
  policy   = "${data.aws_iam_policy_document.manage_users.json}"
  provider = "aws.identity"
}

resource "aws_iam_group_policy_attachment" "enforce_mfa" {
  group      = "${aws_iam_group.admin.id}"
  policy_arn = "${aws_iam_policy.mfa_policy.arn}"
  provider   = "aws.identity"
}

resource "aws_iam_user" "terraform" {
  name     = "terraform"
  path     = "/system/"
  tags     = "${merge(local.common_tags, var.tags)}"
  provider = "aws.identity"
}

resource "aws_iam_user_policy" "terraform_assume_role" {
  name     = "terraform_assume_role"
  user     = "${aws_iam_user.terraform.name}"
  policy   = "${data.aws_iam_policy_document.assume_terraform.json}"
  provider = "aws.identity"
}

resource "aws_iam_access_key" "terraform" {
  user     = "${aws_iam_user.terraform.name}"
  provider = "aws.identity"
}