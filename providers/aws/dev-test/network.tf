
variable "name"                   {}
variable "vpc_cidr"               {}
variable "public_subnets"         {}
variable "app_private_subnets"    {}
variable "db_private_subnets"     {}
variable "azs"                    {}
variable "bastion_public_key"     {}
variable "bastion_private_key"    {}
variable "bastion_instance_type"  {}


module "vpc" {
  source = "../../../modules/aws/network/vpc"

  name = "${var.name}--vpc"
  cidr = "${var.vpc_cidr}"
  tagname = "vpc"
}

module "public_subnet" {
  source = "../../../modules/aws/network/public_subnet"

  name = "${var.name}--public"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs = "${var.public_subnets}"
  azs = "${var.azs}"
  tagname = "app_public_subnet"

}

module "nat" {
  source = "../../../modules/aws/network/nat"

  name              = "${var.name}--nat"
  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
  tagname = "nat_gateway"
}

module "db_private_subnet" {
  source = "../../../modules/aws/network/private_subnet"

  name = "${var.name}--private"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs = "${var.db_private_subnets}"
  azs = "${var.azs}"
  tagname = "db_private_subnet"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

module "app_private_subnet" {
  source = "../../../modules/aws/network/private_subnet"

  name = "${var.name}--private"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs = "${var.app_private_subnets}"
  azs = "${var.azs}"
  tagname = "app_private_subnet"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

module "bastion" {
  source = "../../../modules/aws/network/bastion"

  name                  = "${var.name}--bastion"
  vpc_id                = "${module.vpc.vpc_id}"
  vpc_cidr              = "${module.vpc.vpc_cidr}"
  region                = "${var.region}"
  public_subnet_ids     = "${module.public_subnet.subnet_ids}"
  bastion_public_key    = "${var.bastion_public_key}"
  bastion_private_key   = "${var.bastion_private_key}"
  app_private_key       = "${var.app_private_key}"
  app_public_key        = "${var.app_public_key}"
  bastion_instance_type = "${var.bastion_instance_type}"
  tagname               = "bastion"
  instance_tagname      = "class_jumphost_bastion"
}






