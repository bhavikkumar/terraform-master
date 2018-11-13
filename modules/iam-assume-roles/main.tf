data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowUsersInMasterAccountToAssumeRole"
    effect  = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.master_account_id}:root"
      ]
    }

    condition {
      test      = "BoolIfExists"
      variable  = "aws:MultiFactorAuthPresent"

      values = [
        "true"
      ]
    }
  }
}

resource "aws_iam_role" "admin_role" {
  name                = "Admin"
  assume_role_policy  = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "admin_role" {
  role        = "${aws_iam_role.admin_role.name}"
  policy_arn  = "${var.administrator_default_arn}"
}

resource "aws_iam_role" "engineer_role" {
  name                = "Engineer"
  assume_role_policy  = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "engineer_role" {
  role        = "${aws_iam_role.engineer_role.name}"
  policy_arn  = "${var.engineer_default_arn}"
}

resource "aws_iam_role" "security_audit_role" {
  name                = "SecurityAudit"
  assume_role_policy  = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "security_audit_role" {
  role        = "${aws_iam_role.security_audit_role.name}"
  policy_arn  = "${var.auditor_default_arn}"
}
