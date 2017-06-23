variable "vpc_id"                     {}
variable "app_sg_id"                  {}
variable "db_subnet_ids"              {}

variable "db_engine"                  {}
variable "db_engine_version"          {}
variable "db_instance_class"          {}
variable "db_username"                {}
variable "db_password"                {}
variable "db_multiaz"                 {}
variable "db_skip_final_snapshot"     {}
variable "db_storage_type"            {}
variable "db_storage"                 {}
variable "db_backup_retention_period" {}
variable "db_azs"                     {}

variable "db_family"                  {}
variable "tagname"                    { default = "rds" }
variable "instance_tagname"           { default = "class_dbservers" }


resource "aws_security_group" "rds_sg" {
  vpc_id = "${var.vpc_id}"
  name = "rds-sg"
  description = "RDS security group"
  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = ["${var.app_sg_id}"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      self = true
  }
  tags {
    Name = "${format("%s_%s", var.tagname, "security_group")}"
  }
}

resource "aws_db_subnet_group" "app_db_subnet" {
  name = "app-db-subnet"
  description = "RDS subnet group"
  # Converts a list like "a,b" into ["a", "b"]
  subnet_ids = ["${split(",", var.db_subnet_ids)}"]

  tags {
    Name = "${format("%s_%s", var.tagname, "db_subnet_group")}"
  }
}

resource "aws_db_parameter_group" "app_db_parameters" {
  name = "app-db-parameters"
  family = "${var.db_family}"
  description = "Application database parameter group"

  parameter {
    name = "max_allowed_packet"
    value = "16777216"
  } 

  tags {
    Name = "${format("%s_%s", var.tagname, "db_parameter_group")}"
  }
}


resource "aws_db_instance" "app_db" {
  allocated_storage    = "${var.db_storage}"
  engine               = "${var.db_engine}"
  engine_version       = "${var.db_engine_version}"
  instance_class       = "${var.db_instance_class}"
  identifier           = "appdb"
  name                 = "appdb"
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  db_subnet_group_name = "${aws_db_subnet_group.app_db_subnet.name}"
  parameter_group_name = "${aws_db_parameter_group.app_db_parameters.name}"
  multi_az             = "${var.db_multiaz}"
  skip_final_snapshot  = "${var.db_skip_final_snapshot}"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  storage_type         = "${var.db_storage_type}"
  backup_retention_period = "${var.db_backup_retention_period}"
  availability_zone = "${element(split(",", var.db_azs), 0)}"   # prefered AZ
  tags {
    Name = "${format("%s_%s", var.instance_tagname, "instance")}"
  }
}

output "rds_endpoint" { value = "${aws_db_instance.app_db.endpoint}" }
output "rds_sg_id" { value = "${aws_security_group.rds_sg.id}"}
