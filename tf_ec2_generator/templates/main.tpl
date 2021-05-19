provider \"aws\" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}

terraform {
  backend \"s3\" {
    bucket               = \"2u-terraform\"
    region               = \"us-east-1\"
    workspace_key_prefix = \"it-inf-acct/resources\"
    key                  = ${remote_state_key}
    dynamodb_table       = \"terraform-locks\"
  }
}