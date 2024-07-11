terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.76.1"
      configuration_aliases = [ aws ]
    }
  }
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 16
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
  hard_expiry                    = true
}
