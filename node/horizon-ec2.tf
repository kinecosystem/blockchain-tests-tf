##################
# EC2 Horizon  ##
#################
resource "aws_instance" "horizon-test-fed" {
   ami  = "${var.horizon_1_ami}"
   #ami = "${data.aws_ami.latest-ubuntu.id}"
   user_data = "${file("userdata-core.txt")}"
   instance_type = "c5.large"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${var.subnetdeploy}"
   vpc_security_group_ids = ["${var.sgdeploy-horizon}"]
   associate_public_ip_address = false
   source_dest_check = false
   iam_instance_profile = "${var.iamcoredeploy}"
root_block_device {
    volume_size = "50"
    volume_type = "standard"
  }

  tags = {
    Name = "horizon-test-fed-${var.SUFFIX}"
  }
}

