resource "aws_cloudwatch_event_permission" "allow_organization" {
  principal    = "*"
  statement_id = "OrganizationAccess"

  condition {
    key   = "aws:PrincipalOrgID"
    type  = "StringEquals"
    value = aws_organizations_organization.org.id
  }
  provider = aws.operations
}