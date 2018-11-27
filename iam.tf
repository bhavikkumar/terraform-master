// Create a policy for requiring MFA
// This policy is described in https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_users-self-manage-mfa-and-creds.html
data "aws_iam_policy_document" "mfa" {
  statement {
    sid     = "AllowAllUsersToListAccounts"
    effect  = "Allow"

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
    sid     = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"
    effect  = "Allow"

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
      "arn:aws:iam::${var.master_account_id}:user/$${aws:username}"
    ]
  }

  statement {
    sid     = "AllowIndividualUserToViewAndManageTheirOwnMFA"
    effect  = "Allow"

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
    sid     = "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA"
    effect  = "Allow"

    actions = [
      "iam:DeactivateMFADevice"
    ]

    resources = [
      "arn:aws:iam::${var.master_account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${var.master_account_id}:user/$${aws:username}"
    ]
  }

  statement {
    sid     = "BlockMostAccessUnlessSignedInWithMFA"
    effect  = "Deny"

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

    not_resources = [
      "*"
    ]

    condition {
      test      = "BoolIfExists"
      variable  = "aws:MultiFactorAuthPresent"

      values = [
        "false"
      ]
    }
  }

  provider = "aws.master"
}

data "aws_iam_policy_document" "admin_group" {
  statement {
    sid     = "AllowUsersToAssumeTheAdminOrReadOnlyRole"
    effect  = "Allow"

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
    sid     = "AllowUsersToAssumeTheEngineerRole"
    effect  = "Allow"

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
    sid     = "AllowUsersToAssumeTheSecurityAuditRole"
    effect  = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      "arn:aws:iam::*:role/SecurityAudit"
    ]
  }
}

module "iam-assume-roles-operations" {
  source            = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"

  providers = {
    aws = "aws.operations"
  }
}

module "iam-assume-roles-development" {
  source            = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"

  providers = {
    aws = "aws.development"
  }
}

module "iam-assume-roles-production" {
  source            = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"

  providers = {
    aws = "aws.production"
  }
}

resource "aws_iam_group" "admin" {
  name      = "Admin"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_admin" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.admin.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "admin_assume_role" {
  name      = "admin-assume-role"
  group     = "${aws_iam_group.admin.id}"
  policy    = "${data.aws_iam_policy_document.admin_group.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy_attachment" "admin_iam" {
  group       = "${aws_iam_group.admin.id}"
  policy_arn = "${var.iam_admin_arn}"
  provider    = "aws.master"
}

resource "aws_iam_group_policy_attachment" "admin_billing" {
  group       = "${aws_iam_group.admin.id}"
  policy_arn  = "${var.billing_default_arn}"
  provider    = "aws.master"
}

resource "aws_iam_group" "engineer" {
  name      = "Engineer"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_engineer" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.engineer.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "engineer_assume_role" {
  name      = "engineer-assume-role"
  group     = "${aws_iam_group.engineer.id}"
  policy    = "${data.aws_iam_policy_document.engineer_group.json}"
  provider  = "aws.master"
}

resource "aws_iam_group" "security_audit" {
  name      = "Audit"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_security" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.security_audit.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "security_audit_assume_role" {
  name      = "security-audit-assume-role"
  group     = "${aws_iam_group.security_audit.id}"
  policy    = "${data.aws_iam_policy_document.security_audit_group.json}"
  provider  = "aws.master"
}

resource "aws_iam_group" "finance" {
  name      = "Finance"
  provider  = "aws.master"
}

resource "aws_iam_group_policy" "mfa_finance" {
  name      = "mfa-policy"
  group     = "${aws_iam_group.finance.id}"
  policy    = "${data.aws_iam_policy_document.mfa.json}"
  provider  = "aws.master"
}

resource "aws_iam_group_policy_attachment" "billing_attach" {
  group       = "${aws_iam_group.finance.id}"
  policy_arn  = "${var.billing_default_arn}"
  provider    = "aws.master"
}
