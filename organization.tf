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