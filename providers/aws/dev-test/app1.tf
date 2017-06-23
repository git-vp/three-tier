# File created by Venugopal Panchamukhi

variable "amis"                { type = "map" }
variable "app_instance_type"   {}
variable "app_private_key"     {}
variable "app_public_key"      {}

module "app1" {
  source = "../../../modules/aws/compute/ec2"

  vpc_id = "${module.vpc.vpc_id}"
  ingress_sg_id = "${module.bastion.bastion_sg_id}"
  amis = "${var.amis}"
  region = "${var.region}"
  app_subnet_id = "${element(split(",", module.app_private_subnet.subnet_ids), 0)}"
  app_instance_type = "${var.app_instance_type}"
  bastion_host = "${module.bastion.bastion_public_ip}"
  bastion_private_key = "${var.bastion_private_key}"
  app_private_key = "${var.app_private_key}"
  app_public_key = "${var.app_public_key}"
  tagname = "app1"
  instance_tagname = "class_appservers_app1"
}


output "configuration" {
  value = <<CONFIGURATION

  Bastion Host Public IP: ${module.bastion.bastion_public_ip}
  Application Private IP: ${module.app1.private_ip}
  Database Server Endpoint: ${module.rds.rds_endpoint}
  CONFIGURATION
}

