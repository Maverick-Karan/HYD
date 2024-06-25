## create new account in VPC
module "new_account" {
  source                  = "./modules/account"
  name                    = var.name
  email                   = var.email
  role_name               = var.role_name
  providers               = {
                              aws = aws.master
                            }
}