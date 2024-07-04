// Create new account under OU-Project
module "new_account" {
  source    = "./modules/account"
  name      = "${var.name}"
  email     = "${var.email}"
  parent_id = "${var.parent_id}"
  role_name = "${var.role_name}"
}


// Python script to delete default VPC
module "delete_vpc" {
  source    = "./modules/python"
  new_account_id  = module.new_account.new_account_id
//depends_on      = [module.new_account]
}