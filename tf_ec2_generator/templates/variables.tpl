variable \"instance_name\" {
  description = \"full instance name used for tags\"
  default = ${instance_name}
}
variable \"instance_name_prefix\" {
  description = \"prefix of instance name, module will append nubmer  based on instance count\"
  default = ${instance_name_prefix}
}
variable \"region\" {
  default = ${region}
}
variable \"zone\" {
  default = ${region_zone}
}
variable \"size\" {
  type = map
  description = \"instance size\"
  default = {
    prod = ${instance_size_prod}
    dev = ${instance_size_dev}
  }
}
variable \"key\" {
  type        = map
  description = \"private key\"
  default = {
    prod      = ${private_key_prod}
    dev       = ${private_key_dev}
  }
}
variable \"role_arn\" {
  default = \"arn:aws:iam::731933753003:role/OrganizationAccountAccessRole\"
}
variable \"vsize\" {
  default = ${instance_volume_size}
}

variable \"regional_vpc_state\" {
  type = map
  description = \"regional vpc state\"
  default = {
    prod = \"it-inf-acct/resources/prod/${region_short}/vpc.tfstate\" 
    dev = \"it-inf-acct/resources/dev/${region_short}/vpc.tfstate\"
  }
}
variable \"delegated_acct_tag_state\" {
  default     = \"it-inf-acct/global-resources/tags/terraform.tfstate\"
  description = \"Path to the tfstate for the delegated account tags\"
}
