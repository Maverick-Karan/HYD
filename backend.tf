terraform {
  backend "s3" {
    bucket         = "hyd-remotestate"
    key            = "default/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "hyd-state-locking"
    encrypt        = "true"
  }
}