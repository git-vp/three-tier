
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
variable "db_family"                  {}

module "rds" {
  source = "../../../modules/aws/storage/rds"

  vpc_id = "${module.vpc.vpc_id}"
  app_sg_id = "${module.app1.sg_id}"
  db_subnet_ids = "${module.db_private_subnet.subnet_ids}"
  db_engine = "${var.db_engine}"
  db_engine_version = "${var.db_engine_version}"
  db_instance_class = "${var.db_instance_class}"
  db_username = "${var.db_username}"
  db_password = "${var.db_password}"
  db_multiaz = "${var.db_multiaz}"
  db_skip_final_snapshot = "${var.db_skip_final_snapshot}"
  db_storage_type = "${var.db_storage_type}"
  db_storage = "${var.db_storage}"
  db_backup_retention_period = "${var.db_backup_retention_period}"
  db_azs = "${var.azs}"
  db_family = "${var.db_family}"
  tagname = "appdb"
  instance_tagname = "class_dbservers_appdb"
}


