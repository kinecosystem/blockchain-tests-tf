#################################
# Fetch latest Ubuntu in Region #
#################################

data "aws_ebs_snapshot" "ebs_volume" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["LatestCoreData3"]
  }
}