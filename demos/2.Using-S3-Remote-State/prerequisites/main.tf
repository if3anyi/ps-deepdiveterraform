##################################################################################
# PROVIDERS
##################################################################################
provider "aws" {
  region                                = "${var.platform_region}"
  shared_credentials_file               = "${var.shared_credentials}"
  profile                               = "${var.your_profile}"
}

data "aws_iam_group" "ec2admin" {
    group_name = "im_operations"
}

##################################################################################
# RESOURCES
##################################################################################
resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "${var.aws_dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "ddtnet" {
  bucket = "${var.aws_networking_bucket}"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

      policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforAppTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.sallysue.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_networking_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.marymoe.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_networking_bucket}",
                "arn:aws:s3:::${var.aws_networking_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "ddtapp" {
  bucket = "${var.aws_application_bucket}"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
        policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadforNetTeam",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.marymoe.arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.aws_application_bucket}/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.sallysue.arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_application_bucket}",
                "arn:aws:s3:::${var.aws_application_bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user" "sallysue" {
  name = "sallysue"
}

resource "aws_iam_user_policy" "sallysue_rw" {
    name = "sallysue"
    user = "${aws_iam_user.sallysue.name}"
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_application_bucket}",
                "arn:aws:s3:::${var.aws_application_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_user" "marymoe" {
    name = "marymoe"
}

resource "aws_iam_access_key" "marymoe" {
    user = "${aws_iam_user.marymoe.name}"
}

resource "aws_iam_user_policy" "marymoe_rw" {
    name = "marymoe"
    user = "${aws_iam_user.marymoe.name}"
   policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.aws_networking_bucket}",
                "arn:aws:s3:::${var.aws_networking_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${aws_dynamodb_table.terraform_statelock.arn}"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_access_key" "sallysue" {
    user = "${aws_iam_user.sallysue.name}"
}

resource "aws_iam_group_membership" "addsally" {
    name = "add-sally"

    users = [
        "${aws_iam_user.sallysue.name}"
    ]

    group = "im_operations"
}

resource "local_file" "aws_keys" {
    content = <<EOF
[sallysue]
aws_access_key_id = ${aws_iam_access_key.sallysue.id}
aws_secret_access_key = ${aws_iam_access_key.sallysue.secret}

[marymoe]
aws_access_key_id = ${aws_iam_access_key.marymoe.id}
aws_secret_access_key = ${aws_iam_access_key.marymoe.secret}

EOF
    filename = "${var.user_home_path}/.aws/credentials-sandbox"

}
