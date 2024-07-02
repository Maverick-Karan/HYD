provider "aws" {
  alias  = "master"
  region = "us-east-1"
  #assume_role {
  #  role_arn = "arn:aws:iam::664967790151:role/<ROLE_NAME>"
  #}
}


// Create new account under OU-Project
resource "aws_organizations_account" "new_account" {
  name      = "${var.name}"
  email     = "${var.email}"
  parent_id = "${var.parent_id}"
  role_name = "${var.role_name}"
}


// Python script to delete default VPC
resource "null_resource" "delete_default_vpc" {
  provisioner "local-exec" {
    command = <<EOT
    python3 delete_default_vpc.py ${aws_organizations_account.new_account.id}
    EOT
  }
  depends_on = [aws_organizations_account.new_account]
}