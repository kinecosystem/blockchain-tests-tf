##############################
#   Application VPC          #
##############################

# Define our VPC
resource "aws_vpc" "Application-VPC" {
  cidr_block = "${var.VPC_CIDR}${var.app_vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "Stellar-Tests-VPC-${var.SUFFIX}"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.Application-VPC.id}"

  tags = {
    Name = "Stellar-Tests-IGW-${var.SUFFIX}"
  }
}

# Connects Managment route table to Peering of Tests-VPC
# Define the public route table
#resource "aws_route" "peering-mgmt-to-tests" {
#  vpc_id = "vpc-080d4cf2e782cf760"
#  route_table_id = "rtb-0e0cadd5d7d99912c"
#  route {
#    cidr_block = "172.31.0.0/16"
#    gateway_id = "${aws_vpc_peering_connection.jenkinstocore.id}"
#  }
#}

# Define the public route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.Application-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  route {
    cidr_block = "10.10.0.0/16"
    gateway_id = "${aws_vpc_peering_connection.jenkinstocore.id}"
  }
  tags = {
    Name = "Fed-Public-RT-${var.SUFFIX}"
  }
}

resource "aws_main_route_table_association" "public-main-rt" {
  vpc_id         = "${aws_vpc.Application-VPC.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

###################

# Define the private route table
resource "aws_route_table" "web-private-rt" {
  vpc_id = "${aws_vpc.Application-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.stellar_nat_gw.id}"
  }
  route {
    cidr_block = "10.10.0.0/16"
    gateway_id = "${aws_vpc_peering_connection.jenkinstocore.id}"
  }

  route {
    cidr_block = "10.100.0.0/16"
    gateway_id = "${aws_vpc_peering_connection.mgmttocore.id}"
  }

  tags = {
    Name = "Fed-Private-RT-${var.SUFFIX}"
  }
}

# Assign the route table to the Private Subnet
resource "aws_route_table_association" "fed-rt-attach" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.web-private-rt.id}"
}

resource "aws_route_table_association" "fed-rt-attach-b" {
  subnet_id = "${aws_subnet.private-subnet-b.id}"
  route_table_id = "${aws_route_table.web-private-rt.id}"
}
