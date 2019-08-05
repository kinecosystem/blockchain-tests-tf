###############################
##   AWS  Connection config ##
##############################
//todo: add folders for clearer structure?
//todo: save state to S3 bucket
provider "aws" {
  profile    = "${var.profile}"
  region     = "${var.aws_region}"
}
