variable "name" { default = "vpc" }
variable "cidr" {}
variable "tagname" { default = "vpc" }

# Internet VPC
resource "aws_vpc" "main" {
	cidr_block = "${var.cidr}"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
		Name = "${var.tagname}"
    }
}

output "vpc_id" { value = "${aws_vpc.main.id}" }
output "vpc_cidr" { value = "${aws_vpc.main.cidr_block}" }


