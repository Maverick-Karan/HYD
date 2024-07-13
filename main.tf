// Create new account under OU-Project
module "new_account" {
  source    = "./modules/account"
  name      = "${var.name}"
  email     = "${var.email}"
  parent_id = "${var.parent_id}"
  role_name = "OrganizationAccountAccessRole"
}


// Python script to delete default VPC
module "delete_vpc" {
  source    = "./modules/python"
  new_account_id  = module.new_account.new_account_id
  depends_on      = [module.new_account]
}

// Create alias for new account
module "IAM_alias" {
  providers = {
    aws = aws.newOrg
  }
  source   = "./modules/alias"
  username = var.username
  depends_on      = [module.new_account]
}


// Set password policy for new account
module "password_policy" {
  providers = {
    aws = aws.newOrg
  }
  source   = "./modules/password_policy"
  depends_on      = [module.new_account]
}