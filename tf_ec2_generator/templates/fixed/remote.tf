# Remote State: Delegated Account Tagging
data "terraform_remote_state" "tags" {
  backend = "s3"

  config = {
    bucket = "2u-terraform"
    key    = var.delegated_acct_tag_state
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "2u-terraform"
        key = var.regional_vpc_state[terraform.workspace]
        region = "us-east-1"
    }
}