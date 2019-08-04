######################
# Peering connection #
######################

resource "aws_vpc_peering_connection" "jenkinstocore" {
  peer_vpc_id   = "vpc-080d4cf2e782cf760"
  vpc_id        = "${aws_vpc.Application-VPC.id}"
  auto_accept   = true

  tags = {
    Name = "VPC Peering between Managment-Vpc and Testing-Vpc-${var.SUFFIX}"
  }
}

resource "aws_vpc_peering_connection" "mgmttocore" {
  peer_vpc_id   = "vpc-0200e5d2b83a9f5f1" 
  vpc_id        = "${aws_vpc.Application-VPC.id}"
  auto_accept   = true

  tags = {
    Name = "VPC Peering between Production-Vpc and Stellar-Vpc-${var.SUFFIX}"
  }
}
