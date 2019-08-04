
# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "default-key-${var.SUFFIX}"
  public_key = "${file("${var.key_path}")}"
}

##################
# EC2 Instances ##
##################
# Define stellar inside the private subnet

#resource "aws_instance" "stellar" {
#   ami = "${data.aws_ami.latest-ubuntu.id}"
#   instance_type = "t3.medium"
#   key_name = "${aws_key_pair.default.id}"
#   subnet_id = "${aws_subnet.private-subnet.id}"
#   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
#   associate_public_ip_address = false
#   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
#root_block_device {
#    volume_size = "100"
#    volume_type = "standard"
#  }   

#  tags = {
#    Name = "Stellar-core-${var.SUFFIX}"
#  }
#}

# Define bastion inside the private subnet
#resource "aws_instance" "bastion" {
#   ami = "${data.aws_ami.latest-ubuntu.id}"
#   instance_type = "t2.micro"
#   key_name = "${aws_key_pair.default.id}"
#   subnet_id = "${aws_subnet.dmz-subnet.id}"
#   vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]
#   source_dest_check = false
#root_block_device {
#    volume_size = "8"
#    volume_type = "standard"
#  }

#  tags = {
#    Name = "Bastion-Host-${var.SUFFIX}"
#  }
#}
###################################


###################################
# Define NAT gateway to Private Subnet
###################################

resource "aws_eip" "nat" {
  #instance = "${aws_instance.web.id}"
  vpc      = true
}


resource "aws_nat_gateway" "stellar_nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-subnet.id}"

  tags = {
    Name = "gw NAT-${var.SUFFIX}"
  }
}

