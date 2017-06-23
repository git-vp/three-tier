  #--------------------------------------------------------------
# This module creates all resources necessary for a private
# subnet
#--------------------------------------------------------------

variable "name"            { default = "private"}
variable "vpc_id"          { }
variable "cidrs"           { }
variable "azs"             { }
variable "nat_gateway_ids" { }
variable "tagname"         { default = "private-subnet" }

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.cidrs))}"

  lifecycle { create_before_destroy = true }

  tags {
    Name = "${format("%s_%s", var.tagname, element(split(",", var.azs), count.index))}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
  count  = "${length(split(",", var.cidrs))}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
  }

  lifecycle { create_before_destroy = true }

  tags {
    Name = "${format("%s_%s_%s", var.tagname, "routetable", element(split(",", var.azs), count.index))}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",", var.cidrs))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  lifecycle { create_before_destroy = true }
}

output "subnet_ids" { value = "${join(",", aws_subnet.private.*.id)}" }
