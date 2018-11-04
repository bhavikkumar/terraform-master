provider "aws" {
  alias = "operations"
  region = "${var.aws_default_region}"
  allowed_account_ids = [
    "${var.master_account_id}",
    "${aws_organizations_account.operations.id}"
  ]
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.operations.id}:role/Admin"
    session_name = "terraform"
  }
}

// Set human readable alias for the account
resource "aws_iam_account_alias" "operations" {
  account_alias = "${var.prefix}-operations"
  provider = "aws.operations"
}

module "iam-assume-roles" {
  source = "./modules/iam-assume-roles"
  master_account_id = "${var.master_account_id}"
  providers = {
    aws = "aws.operations"
  }
}

module "cloudtrail-master" {
  source = "./modules/cloudtrail-master"
  aws_region = "${var.aws_default_region}"
  cloudtrail_account_id = "${aws_organizations_account.operations.id}"
  account_id_list = ["${aws_organizations_account.operations.id}", "${var.master_account_id}"]
  domain_name = "${var.domain_name}"
  providers = {
    aws = "aws.operations"
  }
}

# resource "aws_cloudtrail" "cloudtrail" {
#   name = "operations-cloudtrail"
#   s3_bucket_name = "${aws_s3_bucket.cloudtrail.id}"
#   is_multi_region_trail = true
#   enable_log_file_validation = true
#   kms_key_id = "${aws_kms_key.cloudtrail.arn}"
#   include_global_service_events = true
# }

// Terraform KMS Key
resource "aws_kms_key" "terraform" {
  description = "KMS Key used by Terraform"
  policy = "${data.aws_iam_policy_document.terraform_kms_policy.json}"
  provider = "aws.operations"
}

resource "aws_kms_alias" "terraform" {
  name          = "alias/terraform-key"
  target_key_id = "${aws_kms_key.terraform.key_id}"
  provider = "aws.operations"
}

// Terraform S3 Bucket
resource "aws_s3_bucket" "terraform" {
  bucket = "terraform.${var.domain_name}"
  acl = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = "${aws_kms_key.terraform.arn}"
      }
    }
  }
  provider = "aws.operations"
}

resource "aws_s3_bucket_policy" "encrypt_terraform_bucket" {
  bucket = "${aws_s3_bucket.terraform.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.terraform.id}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "aws:kms"
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.terraform.id}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        },
        {
            "Sid": "DenyDeleteBucket",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:DeleteBucket",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.terraform.id}"
        },
        {
            "Sid": "DenyPolicyUpdateOrDelete",
            "Effect": "Deny",
            "NotPrincipal": {
                "AWS": [
                    "arn:aws:iam::${aws_organizations_account.operations.id}:root",
                    "arn:aws:sts::${aws_organizations_account.operations.id}:assumed-role/OrganizationAccountAccessRole/terraform",
                    "arn:aws:iam::${aws_organizations_account.operations.id}:role/OrganizationAccountAccessRole"
                ]
            },
            "Action": [
                "s3:PutBucketPolicy",
                "s3:DeleteBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.terraform.id}"
        }
    ]
}
POLICY
  provider = "aws.operations"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "terraform-state"
  hash_key = "LockID"
  read_capacity = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }
  provider = "aws.operations"
}
