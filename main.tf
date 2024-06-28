terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"  # Adjust the version as needed
    }
  }
}

provider "aws" {
  alias   = "master"
  region  = "us-east-1"
}


resource "aws_iam_role" "jenkins_role" {
  name = "JenkinsDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::YOUR_JENKINS_ACCOUNT_ID:role/JenkinsRole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  inline_policy {
    name = "AllowAssumeRole"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sts:AssumeRole"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

data "aws_vpcs" "default" {
  provider = aws.assume_role
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

resource "null_resource" "delete_default_vpc" {
  count = length(data.aws_vpcs.default.ids)

  triggers = {
    default_vpc_id = data.aws_vpcs.default.ids[count.index]
  }

  provisioner "local-exec" {
    command = "aws ec2 delete-vpc --vpc-id ${data.aws_vpcs.default.ids[count.index]}"
  }
}

provider "aws" {
  alias  = "assume_role"
  region = "us-west-2"

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.new_account.id}:role/OrganizationAccountAccessRole"
  }
}

resource "aws_organizations_account" "new_account" {
  provider = aws.master

  name      = "${var.name}"
  email     = "${var.email}"
  role_name = "${var.role_name}"
}

#--------------------------------------------------------------------------------

#resource "aws_organizations_account" "new_account" {
#  provider = aws.master

#  name      = "NewAccountName"
#  email     = "new-account@example.com"
#  role_name = "OrganizationAccountAccessRole"
#}

#resource "aws_s3_bucket" "example" {
#  bucket = "muayyybukcitt"

#  tags = {
#    Name        = "My bucket"
#    Environment = "Dev"
#  }
#}

## create new account in VPC
#module "new_account" {
#  source                  = "./modules/account"
#  name                    = var.name
#  email                   = var.email
#  role_name               = var.role_name
#}