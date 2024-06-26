#provider "aws" {
#  alias   = "master"
#  region  = "us-east-1"
#}

resource "aws_organizations_account" "new_account" {
  provider = aws.master

  name      = "${var.name}"
  email     = "${var.email}"
  role_name = "${var.role_name}"
}