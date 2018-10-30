# terraform-aws-account

This terraform module which creates roles which can be assumed by users from the master account if they have the appropriate permissions and MFA enabled.

## Features
The roles which are created are the following:
- Create admin role
- Create engineer role
- Create a security audit role

## Usage
TODO

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
master_account_id | The master account which users will be in to access the roles | string | - | yes
administrator_default_arn | The managed ARN which will be attached to the Admin role | string | arn:aws:iam::aws:policy/AdministratorAccess | no
engineer_default_arn | The managed ARN which will be attached to the Engineer role | string | arn:aws:iam::aws:policy/PowerUserAccess | no
auditor_default_arn | The managed ARN which will be attached to the SecurityAudit role | string | arn:aws:iam::aws:policy/SecurityAudit | no

## Outputs
