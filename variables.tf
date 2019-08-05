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
//todo: get passwords from vault/ssm/other
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

variable "profile" {
  description = "AWS profile"
  default = "default"
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

variable "test_core_ami" {
  description = "Default Core AMI"
  default = "ami-08755ca1546ebe1e7"
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

variable "horizon_instance_type" {
  description = "Horizon instance type"
  default = "c5.large"
}


variable "core_instance_type" {
  description = "Core instance type"
  default = "c5.large"
}

variable "watcher_instance_type" {
  description = "Watcher instance type"
  default = "c5.large"
}
variable "prometheus_instance_type" {
  description = "Prometheus instance type"
  default = "t3.medium"
}

variable "test_client_instance_type" {
  description = "Test client instance type"
  default = "t3.medium"
}


#Amount_of_cores
variable "amount_of_cores" {
  description = "Amount of cores"
  default = "5"
}
