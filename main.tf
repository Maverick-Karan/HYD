## create new account in VPC
module "new_account" {
  source                  = "./modules/new_account"
  region                  = var.region
  name                    = var.name
  email                   = var.email
  role_name               = var.role_name
}