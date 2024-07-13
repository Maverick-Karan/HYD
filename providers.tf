terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.76.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "master"
  region  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::664967790151:role/account-create"
  }
}
provider "aws" {
  alias  = "new"
  region  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${module.new_account.new_account_id}:role/${var.role_name}"
  }
}