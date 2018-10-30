# terraform-master

This terraform project initialises a account to become the root account of an AWS Organisation. The template will create the following resources:

** It is important to note that the resources may not be created in the order listed here **

### Master Account
  - [x] Enable strict password policy
  - [x] Enable AWS Organisations
  - [x] Create an operations account
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

### TODO
  * Turn duplicate code blocks into modules
    * Creation of AWS Account
    * Creation of Roles
    * Creation of CloudTrail
  * Refactor data blocks and policies to reduce duplication
  * When Terraform supports it
    * Automate enabling service control policies
    * Automate attachment of service control policies to accounts

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
