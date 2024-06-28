// Provider configuration
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


// Create a new AWS account within the organization
resource "aws_organizations_account" "new_account" {
  provider = aws.master

  name      = "${var.name}"
  email     = "${var.email}"
  role_name = "${var.role_name}"
}


// Create an IAM role for Jenkins to assume
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
          AWS = "arn:aws:iam::${var.jenkins_account_id}:role/JenkinsRole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  
   // Attach an inline policy to the role
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


// Provider configuration to assume the role in the new AWS account
provider "aws" {
  alias  = "assume_role"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.new_account.id}:role/OrganizationAccountAccessRole"
  }
}


// Data source to fetch default VPCs in the new AWS account
data "aws_vpcs" "default" {
  provider = aws.assume_role
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}


// Resource to delete the default VPCs
resource "null_resource" "delete_default_vpc" {
  count = length(data.aws_vpcs.default.ids)

  triggers = {
    default_vpc_id = data.aws_vpcs.default.ids[count.index]
  }

  provisioner "local-exec" {
    command = "aws ec2 delete-vpc --vpc-id ${data.aws_vpcs.default.ids[count.index]}"
  }
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