module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  instance_count              = "1"
  ami                         = data.aws_ami.windows.id #latest windows ami, see data.tf
  instance_type               = var.size[terraform.workspace]
  key_name                    = var.key[terraform.workspace]
vpc_security_group_ids      = [data.terraform_remote_state.vpc.outputs.allow_twou_private_sg_id]
  subnet_id                  = data.terraform_remote_state.vpc.outputs.private_subnets_ids[0] #terraform.workspace == "dev" ? data.terraform_remote_state.dev_vpc.outputs.private_subnets_ids : data.terraform_remote_state.prod_vpc.outputs.private_subnets_ids
  name                        = var.instance_name_prefix
  use_num_suffix              = true #add number of instance count to name 
  num_suffix_format           = "0%d" #sets num prefix to include 0# 
  root_block_device = [{
    volume_size = var.vsize
    volume_type = "gp2"
  }]
  tags = merge(
    data.terraform_remote_state.tags.outputs.resource_default,
    {
      Name = var.instance_name
      Environment = terraform.workspace
    }
  )
}
