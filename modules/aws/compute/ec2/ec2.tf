variable "vpc_id"              {}
variable "ingress_sg_id"       {}
variable "amis"                { type = "map" }
variable "region"              {}
variable "app_subnet_id"       {}
variable "app_instance_type"   {}
variable "bastion_host"        {}
variable "bastion_private_key" {}
variable "app_private_key"     {}
variable "app_public_key"      {}
variable "tagname"                { default = "app" }
variable "instance_tagname"    { default = "class_appservers" }

resource "aws_security_group" "app_sg" {
  vpc_id = "${var.vpc_id}"
  name = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = ["${var.ingress_sg_id}"]
  }
  tags {
    Name = "${format("%s_%s", var.tagname, "sg")}"
  }
}

resource "aws_key_pair" "app_key_pair" {
  key_name = "app_key_pair"
  public_key = "${file("${var.app_public_key}")}"
}


resource "aws_instance" "app_instance" {
  ami           = "${lookup("${var.amis}", "${var.region}")}"
  instance_type = "${var.app_instance_type}"

  # the VPC subnet
  subnet_id = "${var.app_subnet_id}"

  # the security group
  vpc_security_group_ids = ["${aws_security_group.app_sg.id}"]

  # the public SSH key
  key_name = "${aws_key_pair.app_key_pair.key_name}"

  tags {
    Name = "${format("%s_%s", var.instance_tagname, "instance")}"
  }

  connection {
    user = "ubuntu"
    private_key = "${file(var.app_private_key)}"
    bastion_host = "${var.bastion_host}"
    bastion_private_key = "${file(var.bastion_private_key)}"
    agent = false
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
}

output "public_ip" { value = "${aws_instance.app_instance.public_ip}"}
output "public_dns" { value = "${aws_instance.app_instance.public_dns}"}

output "private_ip" { value = "${aws_instance.app_instance.private_ip}" }
output "private_dns" { value = "${aws_instance.app_instance.private_dns}"}

output "sg_id" { value = "${aws_security_group.app_sg.id}"}
