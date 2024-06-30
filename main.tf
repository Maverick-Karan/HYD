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


// Data source to get the current account ID
data "aws_caller_identity" "master" {
  provider = aws.master
}

// Create a new AWS account within the organization
resource "aws_organizations_account" "new_account" {
  provider = aws.master
  name     = var.name
  email    = var.email
  role_name = "OrganizationAccountAccessRole"
}

// Wait for the account to be ready
resource "null_resource" "wait_for_account" {
  provisioner "local-exec" {
    command = "sleep 300"  // Wait for 5 minutes to ensure the account is ready
  }
  depends_on = [aws_organizations_account.new_account]
}

// Provider configuration to assume the role in the new AWS account
provider "aws" {
  alias  = "assume_role"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.new_account.id}:role/OrganizationAccountAccessRole"
  }
}

// Create the OrganizationAccountAccessRole in the new account
resource "aws_iam_role" "organization_account_access_role" {
  provider = aws.assume_role
  name     = "OrganizationAccountAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.master.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "OrganizationAccountAccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "organizations:DescribeAccount",
            "organizations:ListAccounts",
            "organizations:DescribeOrganization",
            "iam:CreateRole",
            "iam:AttachRolePolicy",
            "iam:PutRolePolicy",
            "sts:AssumeRole"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

// Create a role for Jenkins to assume in the new account
resource "aws_iam_role" "jenkins_role" {
  provider = aws.assume_role
  name     = "JenkinsDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.master.account_id}:role/ExistingJenkinsRole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "AllowFullAccess"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "*"
          Resource = "*"
        }
      ]
    })
  }
}
