# terraform-master

This terraform project initialises a account to become the root account of an AWS Organisation.

![architecture](https://raw.githubusercontent.com/bhavikkumar/terraform-master/master/architecture.png)

### Master Account
  - [x] Enable strict password policy
  - [x] Enable AWS Organisations
  - [x] Create a operations account
  - [x] Create a development account
  - [x] Create a production account
  - [x] Enable CloudTrail Logging
  - [x] Create Organisational SCP to Deny modification or deletion of CloudTrail
  - [x] Create Account Alias
  - [x] Create a admin group with enforced MFA
  - [x] Create a engineer group with enforced MFA
  - [x] Create a finance group with enforced MFA
  - [x] Create a security audit group with enforced MFA
  - [x] Create a read only role
  - [x] Create a security audit role

### Operations Account
  - [x] Create a KMS Key for CloudTrail
  - [x] Create a encrypted S3 bucket for CloudTrail logs
  - [x] Enable CloudTrail Logging
  - [x] Create admin role
  - [x] Create engineer role
  - [x] Create a security audit role
  - [x] Create a KMS Key for terraform
  - [x] Create a encrypted S3 bucket for terraform state
  - [x] Create a DynamoDB table for terraform state locking

### Development Account
  - [x] Enable CloudTrail Logging
  - [x] Create Account Alias
  - [x] Create admin role
  - [x] Create engineer role
  - [x] Create a security audit role

### Production Account
  - [x] Enable CloudTrail Logging
  - [x] Create Account Alias
  - [x] Create admin role
  - [x] Create engineer role
  - [x] Create a security audit role

## Initalise Master Account and Setup Terraform

The following steps are required initalise the master account and terraforms first run. Best practice is to create a `tfvars` file to supply the variables. The `*.tfvars.example` file can be renamed to `*.tfvars` and updated with the appropriate variables.

**The .gitignore is setup to ignore any `.tfvars` variable files as they could contain sensitive information.**

1. Create a AWS account to be the master account and then run the CloudFormation script in `init/terraform-init.yaml`. The CloudFormation script creates the following resources:
    * Terraform User and Credentials

2. Setup the AWS profile using `aws configure --profile terraform-master`. The outputs of the CloudFormation script should be used when prompted.

3. Run `terraform init "-var-file=master.tfvars"`

3. Run `terraform plan "-var-file=master.tfvars"` ensure the appropriate resources are being created. Especially the KMS key and S3 bucket.

4. Run `terraform apply "-var-file=master.tfvars"`

5. Update the `master.tfvars` file with the outputs from the `terraform apply` stage.

6. Add the following backend configuration to the top of `main.tf`.

```
terraform {
 backend "s3" {
   key     = "common/master"
   encrypt = true
 }
}
```

7. Run `terraform init "-backend-config=backend.tfvars"` again and select yes to migrate the state.

8. As the root user login and enable the `DenyCloudTrailModifications` policy.
  * Navigate to AWS Organizations
  * Click on the `Organize accounts` tab
  * On the right hand side under `Root` click `Enable` for Service control policies
  * Click on the `Policies` tab
  * Select the `ProtectAccounts` policy
  * Select `Accounts` from the right hand side
  * Click `Attach` for all of the accounts listed

## User Terraform Setup
Once the state has been stored in S3, users have to run the following command if they are setting up their local environment or if you ever set or change modules or backend configuration for Terraform.
 * `terraform init "-backend-config=backend.tfvars"`

## Inputs
Name | Description | Type | Default | Required
---- | ----------- | ---- | ------- | --------
aws_default_region | The AWS Region to create resources | string | - | yes
billing_default_arn |  The managed ARN which will be attached to the finance group | string | `arn:aws:iam::aws:policy/job-function/Billing` | no
domain_name | The domain name which will be used as the suffix for s3 buckets and email addresses | string | - | yes
master_account_id | The account id which will be the root organisation | string | - | yes
prefix | The prefix to use for resources | string | - | yes
profile | A profile in ~/.aws/credentials which is used for terraform | string | `default` | no
tags | A map of tags to add to all resources | map | `{}` | no

## Outputs
Name | Description
---- | -----------
cloudtrail_bucket_id | The name of the cloudtrail bucket where all trails will be centralised
development_account_alias | The alias of the development account
development_account_id | The development account id
master_account_alias | The alias of the root account
master_account_id | The root account id
operations_account_alias | The alias of the operations account
operations_account_id | The operation account id
production_account_alias | The alias of the production account
production_account_id | The production account id
terraform_bucket_id | The name of the terraform state bucket
terraform_dynamodb_table_name | The name of the terraform dynamodb table
terraform_kms_key_arn | The KMS Key id used by terraform to encrypt the s3 bucket at rest
