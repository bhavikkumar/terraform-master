resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
  ]
  enabled_policy_types          = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
  feature_set                   = "ALL"
  provider                      = aws.master
}

resource "aws_organizations_policy" "cloudtrail-policy" {
  name        = "ProtectAccounts"
  description = "Deny anyone from doing destructive actions"

  content = <<CONTENT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:UpdateTrail",
        "cloudtrail:DeleteTrail",
        "cloudtrail:PutEventSelectors"
      ],
      "Resource": "*"
    }
  ]
}
CONTENT

  provider = aws.master
}

resource "aws_organizations_policy_attachment" "deny-cloudtrail-modification" {
  policy_id = aws_organizations_policy.cloudtrail-policy.id
  target_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "development" {
  name      = "development"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "production" {
  name      = "production"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "identity" {
  name     = "${var.account_prefix}-identity"
  email    = "4d3d4429-00b8-4916-88a6-190f4968e6fc@${var.domain_name}"
  provider = aws.master
}

resource "aws_organizations_account" "operations" {
  name     = "${var.account_prefix}-operations"
  email    = "580a5d93-f5c5-46e5-84f0-140c4bb8bcaf@${var.domain_name}"
  provider = aws.master
}

resource "aws_organizations_account" "development" {
  name     = "${var.account_prefix}-development"
  email    = "d9ebfd25-4f30-44c8-8c59-07f5ce7be59d@${var.domain_name}"
  parent_id = aws_organizations_organizational_unit.development.id
  provider = aws.master
}

resource "aws_organizations_account" "production" {
  name     = "${var.account_prefix}-production"
  email    = "afb0997b-2275-43f1-a789-4e812f649bbb@${var.domain_name}"
  parent_id = aws_organizations_organizational_unit.production.id
  provider = aws.master
}