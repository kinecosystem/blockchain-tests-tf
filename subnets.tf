######################
# Application - VPC  #
######################

# Define main public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.Application-VPC.id}"
  cidr_block = "${var.VPC_CIDR}${var.public_subnet_cidr}"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Tests-App Public Subnet-1-${var.SUFFIX}"
  }
}


# Define second public subnet
resource "aws_subnet" "public-subnet-b" {
  vpc_id = "${aws_vpc.Application-VPC.id}"
  cidr_block = "${var.VPC_CIDR}${var.public_b_subnet_cidr}"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "Tests-App Public Subnet-2-${var.SUFFIX}"
  }
}

# Define main private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.Application-VPC.id}"
  cidr_block = "${var.VPC_CIDR}${var.private_subnet_cidr}"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "Tests-App Private Subnet-1-${var.SUFFIX}"
  }
}

# Define second private subnet
resource "aws_subnet" "private-subnet-b" {
  vpc_id = "${aws_vpc.Application-VPC.id}"
  cidr_block = "${var.VPC_CIDR}${var.private_subnet_b_cidr}"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Tests-App Private Subnet-2-${var.SUFFIX}"
  }
}
