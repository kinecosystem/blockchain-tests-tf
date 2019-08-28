##################
# EC2 Instances ##
##################
resource "aws_instance" "core-test-fed" {
   ami  = "${var.test_core_ami}"
   #ami = "${data.aws_ami.latest-ubuntu.id}"
   user_data = "${file("userdata-core.txt")}"
   instance_type = "${var.instance_type}"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${var.subnetdeploy}"
   vpc_security_group_ids = ["${var.sgdeploy}"]
   associate_public_ip_address = false
   source_dest_check = false
   iam_instance_profile = "${var.iamcoredeploy}"
root_block_device {
    volume_size = "50"
    volume_type = "standard"
  }
ebs_block_device {
    device_name = "/dev/sdf"
    snapshot_id = "${data.aws_ebs_snapshot.ebs_volume.id}"
    #snapshot_id = "${var.latestcoresnap}"
}
  tags = {
    Name = "core-test-fed-${var.SUFFIX}"
  }
}
