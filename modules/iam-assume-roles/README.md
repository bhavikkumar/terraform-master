# iam-assume-roles

This terraform module which creates roles which can be assumed by users from the master account if they have the appropriate permissions and MFA enabled.

## Features
The roles which are created are the following:
- Create admin role

## TODO
- Enforce MFA on assume role, this only happens if it exists at the moment.

## Usage
```
module "iam-assume-roles" {
  source = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"
  providers = {
    aws = "aws.operations"
  }
}
```

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
master_account_id | The master account which users will be in to access the roles | string | - | yes
administrator_default_arn | The managed ARN which will be attached to the Admin role | string | arn:aws:iam::aws:policy/AdministratorAccess | no

## Outputs
