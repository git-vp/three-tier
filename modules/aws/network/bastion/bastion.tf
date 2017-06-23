#--------------------------------------------------------------
# This module creates all resources necessary for a Bastion
# host
#--------------------------------------------------------------

variable "name"                  { default = "bastion" }
variable "vpc_id"                { }
variable "vpc_cidr"              { }
variable "region"                { }
variable "public_subnet_ids"     { }
variable "bastion_instance_type" { }
variable "bastion_private_key"   { }
variable "bastion_public_key"    { } 
variable "app_private_key"       { }
variable "app_public_key"        { }
variable "tagname"               { default = "bastion" }
variable "instance_tagname"      { default = "class_jumphost_bastion" }

resource "aws_security_group" "bastion" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion security group"

  tags      { Name = "${var.name}" }
  lifecycle { create_before_destroy = true }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${format("%s_%s", var.tagname, "sg")}"
  }
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name = "bastion_key_pair"
  public_key = "${file("${var.bastion_public_key}")}"
}

module "ami" {
  source        = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  instance_type = "${var.bastion_instance_type}"
  region        = "${var.region}"
  distribution  = "trusty"
}

resource "aws_instance" "bastion" {
  ami                         = "${module.ami.ami_id}"
  instance_type               = "${var.bastion_instance_type}"
  subnet_id                   = "${element(split(",", var.public_subnet_ids), 0)}"
  key_name                    = "${aws_key_pair.bastion_key_pair.key_name}"

  connection {
    user = "ubuntu"
    private_key = "${file(var.bastion_private_key)}"
    #agent = true
  }

  provisioner "file" {
    source      = "${var.app_private_key}"
    destination = "/tmp/appkey"
  }

  provisioner "file" {
    source      = "${var.app_public_key}"
    destination = "/tmp/appkey.pub"
  }

  provisioner "remote-exec" {
    inline = [
	  "sudo chmod 400 /tmp/appkey*"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
	  "sudo sh -c \"sed 's/\r//' /tmp/bootstrap.sh > /tmp/bootstrap_new.sh\"",
	  "sudo rm -rf /tmp/bootstrap.sh",
	  "sudo mv /tmp/bootstrap_new.sh /tmp/bootstrap.sh",
	  "sudo rm -rf /tmp/bootstrap_new.sh",
	  "sudo chmod +x /tmp/bootstrap.sh",
          "/tmp/bootstrap.sh"
    ]
  }

  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true

  tags {
    Name = "${format("%s_%s", var.instance_tagname, "instance")}"
  }
  lifecycle { create_before_destroy = true }
}

output "bastion_user"       { value = "ubuntu" }
output "bastion_private_ip" { value = "${aws_instance.bastion.private_ip}" }
output "bastion_public_ip"  { value = "${aws_instance.bastion.public_ip}" }
output "bastion_sg_id" { value = "${aws_security_group.bastion.id}"}
