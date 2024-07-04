provider "aws" {
  alias   = "master"
  region  = "us-east-1"
}

// Create new account under OU-Project
resource "aws_organizations_account" "new_account" {
  name      = "${var.name}"
  email     = "${var.email}"
  parent_id = "${var.parent_id}"
  role_name = "${var.role_name}"
}