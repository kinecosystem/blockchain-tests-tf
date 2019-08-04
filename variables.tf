#########################
# Variables to override #
#########################

variable "NODENAME" {
  description = "The Name of the Node Partner"
  default = "node"
}

variable "SUFFIX" {
  description = "Unique suffix for Node"
  default = "suf42"
}

variable "VPC_CIDR" {
  description = "Unique CIDR for VPC"
  default = "172.32"
}

variable "DB_USER" { default = "stellar" }
variable "DB_PASS" { default = "defaultpassword" }
variable "DB_NAME" { default = "core" }
variable "DB_IDENTIFIER" { default = "stellar-core-db" }

#####################
# Key to launch EC2 #
#####################
variable "job_folder" {
  description = "SSH Public Key path"
  default = "terraform-test2"
}

variable "job_workspace" {
  description = "SSH Public Key path"
  default = "/var/jenkins_home/workspace/Test-Job3/"
}

variable "key_path" {
  description = "SSH Public Key path"
  #default = "/root/.ssh/id_rsa.pub"
  default = "/var/jenkins_home/workspace/Test-Job/terraform-test2/ec2key/key.pub"
}

#######################
# Region to deploy on #
#######################

variable "aws_region" {
  description = "Region for the VPC"
}

#######################
# Application Subnets # 
#######################

variable "app_vpc_cidr" {
  description = "CIDR for the VPC"
  default = ".0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = ".16.0/20"
}

variable "public_b_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = ".32.0/20"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = ".0.0/20"
}

variable "private_subnet_b_cidr" {
  description = "CIDR for the private subnet"
  default = ".48.0/20"
}

variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-0d8f6eb4f641ef691"
}


###################
#  Default AMI's  #
###################

variable "prometheus" {
  description = "Default Prometheus AMI"
  default = "ami-0096cd1e99da3dfb9"
}

variable "test_core_1_ami" {
  description = "Default Node-1 AMI"
  default = "ami-06aa0a01d289e025e"
}

variable "test_core_2_ami" {
  description = "Default Node-2 AMI"
  default = "ami-026fedbbacb6e35f4"
}

variable "test_core_3_ami" {
  description = "Default Node-3 AMI"
  default = "ami-0d08632fc8e34d3a0"
}

variable "test_core_4_ami" {
  description = "Default Node-4 AMI"
  default = "ami-0111ad1f91718b63f"
}

variable "test_core_5_ami" {
  description = "Default Node-5 AMI"
  default = "ami-07415f0e195ef2ea4"
}

variable "horizon_1_ami" {
  description = "Default Horizon-1 AMI"
  default = "ami-0752ca2cd8405d12e"
}

variable "test_load_client_ami" {
  description = "Load Test AMI"
  default = "ami-0f38a2d9e036ded9e"
}

variable "test_watcher_core_1_ami" {
  description = "Load Test AMI"
  default = "ami-0023e946265a2f4d5"
}

