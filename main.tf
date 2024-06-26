## create new account in VPC
#module "new_account" {
#  source                  = "./modules/account"
#  name                    = var.name
#  email                   = var.email
#  role_name               = var.role_name
#}

provider "aws" {
  alias   = "master"
  region  = "us-east-1"
}

#resource "aws_organizations_account" "new_account" {
#  provider = aws.master

#  name      = "${var.name}"
#  email     = "${var.email}"
#  role_name = "${var.role_name}"
#}

resource "aws_s3_bucket" "example" {
  bucket = "muayyybukcitt"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

#resource "aws_organizations_account" "new_account" {
#  provider = aws.master
#
#  name      = "NewAccountName"
#  email     = "new-account@example.com"
#  role_name = "OrganizationAccountAccessRole"
#}