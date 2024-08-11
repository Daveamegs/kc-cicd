terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "dave"

}

module "vpc" {
  source   = "./modules/vpc"
  vpc_name = "KCVPC"
}

module "subnet" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
}

module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
}


module "route_table" {
  source              = "./modules/route_table"
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.subnet.public_subnet_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
}

module "security_groups" {
  source              = "./modules/security_groups"
  internet_cidr_block = module.route_table.internet_cidr_block
  vpc_id              = module.vpc.vpc_id
  local_ip            = var.local_ip
}

module "nacls" {
  source           = "./modules/nacls"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.subnet.public_subnet_id
  local_ip         = var.local_ip
}

module "instances" {
  source               = "./modules/instances"
  ami                  = var.ami
  instance_type        = var.instance_type
  public_subnet_id     = module.subnet.public_subnet_id
  public_sg_id         = module.security_groups.public_sg_id
  key_name             = var.key_name
  private_ssh_key_path = var.private_ssh_key_path
}
