###############################
##   AWS  Connection config ##
##############################

provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "${var.job_workspace}${var.job_folder}/credentials"
  profile                 = "default"
}

