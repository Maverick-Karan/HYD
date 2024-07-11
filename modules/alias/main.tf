terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.76.1"
      configuration_aliases = [ aws ]
    }
  }
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "${var.username}"
}

resource "random_id" "alias_number" {
  byte_length = 2
}
