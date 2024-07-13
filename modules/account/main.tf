# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "= 3.76.1"
#       configuration_aliases = [ aws ]
#     }
#   }
# }

// Create new account under OU-Project
resource "aws_organizations_account" "new_account" {
  name      = "${var.name}"
  email     = "${var.email}"
  parent_id = "${var.parent_id}"
  role_name = "${var.role_name}"
}