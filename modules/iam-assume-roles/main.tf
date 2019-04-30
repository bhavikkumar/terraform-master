data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AllowUsersInMasterAccountToAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${var.account_id}:root"
      ]
    }

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "true"
      ]
    }
  }
}

resource "aws_iam_role" "admin_role" {
  name               = "Admin"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "admin_role" {
  count      = "${var.enable_read_only_for_admin ? 0 : 1}"
  role       = "${aws_iam_role.admin_role.name}"
  policy_arn = "${var.administrator_default_arn}"
}

resource "aws_iam_role_policy_attachment" "admin_billing" {
  role       = "${aws_iam_role.admin_role.name}"
  policy_arn = "${var.billing_default_arn}"
}

resource "aws_iam_role_policy_attachment" "admin_read_only" {
  role       = "${aws_iam_role.admin_role.name}"
  policy_arn = "${var.read_only_default_arn}"
}
