name              = "dev-test"
artifact_type     = "amazon.image" 
region            = "eu-west-1"
profile           = "default"

#-------------------------------------------------------------- 
# Network 
#--------------------------------------------------------------
 
vpc_cidr        = "10.0.0.0/16" 
azs             = "eu-west-1a,eu-west-1b" # AZs are region specific 
db_private_subnets = "10.0.4.0/24,10.0.5.0/24" # Creating one private subnet per AZ
app_private_subnets = "10.0.3.0/24"
public_subnets  = "10.0.1.0/24,10.0.2.0/24" # Creating one public subnet per AZ


# Bastion Host

region = "eu-west-1"
bastion_public_key = "/vagrant/Workspace/Keys/bastkey.pub"
bastion_private_key = "/vagrant/Workspace/Keys/bastkey"
bastion_instance_type = "t2.micro"

#--------------------------------------------------------------
# Compute
#--------------------------------------------------------------

# Application1
amis {
  us-east-1 = "ami-13be557e"
  us-west-2 = "ami-06b94666"
  eu-west-1 = "ami-844e0bf7"
}
app_instance_type = "t2.micro"
app_private_key = "/vagrant/Workspace/Keys/appkey"
app_public_key = "/vagrant/Workspace/Keys/appkey.pub"

#--------------------------------------------------------------
# Storage
#--------------------------------------------------------------

# Database Instance

db_family = "mariadb10.1"
db_engine = "mariadb"
db_engine_version = "10.1.14"
db_instance_class = "db.t2.micro" # use micro for free tier
db_username = "root"
db_multiaz = "false"
db_skip_final_snapshot = "true"
db_storage_type = "gp2"
db_storage = 100 # 100 GB of storage, gives us more IOPS than a lower number
db_backup_retention_period = 30


 
 
