# iam-assume-roles

This terraform module which creates roles which can be assumed by users from the master account if they have the appropriate permissions and MFA enabled.

## Features
The roles which are created are the following:
- Create admin role with toggle to only have billing and read only permissions

## TODO
- Enforce MFA on assume role, this only happens if it exists at the moment.

## Usage
```
module "iam-assume-roles" {
  source = "./modules/iam-assume-roles"
  account_id = "${var.account_id}"
  providers = {
    aws = "aws.operations"
  }
}
```

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
account_id | The account from where users will be to assume roles from | string | - | yes
administrator_default_arn | The managed ARN which will be attached to the Admin role | string | `arn:aws:iam::aws:policy/AdministratorAccess` | no
billing_default_arn |  The managed ARN which will be attached to the finance group | string | `arn:aws:iam::aws:policy/job-function/Billing` | no
enable_read_only_for_admin | If set to true then the admin role will have billing and read only permissions | `false` | no
read_only_default_arn | The managed ARN which will be attached to groups allowed read only access | `arn:aws:iam::aws:policy/ReadOnlyAccess` | no
tags | A map of tags to add to all resources | map | `{}` | no
terraform_default_arn | The managed ARN which will be attached to to the Terraform role | string | `arn:aws:iam::aws:policy/AdministratorAccess` | no

## Outputs
