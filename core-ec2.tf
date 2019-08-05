###########################
# EC2 Prometheus Server   #
###########################
//todo: extract promethues to a different file, make optional for future production support
// todo: allow creation of a single env for production maintenance

locals {
  timestamp_sanitized = formatdate("YYYY-MM-DD-hh:mm", timestamp())
}


resource "aws_instance" "prometheus_server" {
   ami = "${var.prometheus}"
   instance_type = "${var.prometheus_instance_type}"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "135"
    volume_type = "standard"
  }

  tags = {
    //todo: add environment to tag
    //todo: add owner (user who created the environemnt)?
    //todo: add deletion time?
    Environment = "${var.SUFFIX}"
    Created = "${local.timestamp_sanitized}"
    Name = "Promehteus-Server-${var.SUFFIX}"
  }
}
############################

//todo: extract stellar-load-testing client to a different file, make optional for future production support

###################################
# EC2 stellar-load-testing client #
##################################
resource "aws_instance" "test-load-client-1" {
   ami = "${var.test_load_client_ami}"
   instance_type = "${var.test_client_instance_type}"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "35"
    volume_type = "standard"
  }

  tags = {
    Environment = "${var.SUFFIX}"
    Created = "${local.timestamp_sanitized}"
    Name = "test-load-client-1-${var.SUFFIX}"
  }
}


##################
# EC2 Horizon  ##
#################
resource "aws_instance" "test-horizon-1" {
   ami = "${var.horizon_1_ami}"
   instance_type = "${var.horizon_instance_type}"
   key_name = "${aws_key_pair.default.id}"
    //todo: replace instance configuration in user-data with Ansible
   user_data = <<-EOF
   #!/usr/bin/env bash
   sudo rm -rf /data/postgresql
   sudo rm -rf /data/horizon-volumes
   sudo docker-compose -f /data/docker-compose.yml down
   sudo docker-compose -f /data/docker-compose.yml up -d horizon-db
   sleep 14
   sudo docker-compose -f /data/docker-compose.yml run --rm horizon db init
   sleep 2
   sudo docker-compose -f /data/docker-compose.yml up -d
   EOF
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "50"
    volume_type = "standard"
  }

  tags = {
    Environment = "${var.SUFFIX}"
    Created = "${local.timestamp_sanitized}"
    Name = "test-horizon-1-${var.SUFFIX}"
  }
}
//todo: attach EBS from snapshot




##################
# EC2 Instances ##
##################
# Define stellar inside the private subnet

//variable "cores_name" {
//  description = "Cores names"
//  type        = list(number)
//  default     = [1,2,3,4,5]
//}


resource "aws_instance" "test-cores" {
   count = "${var.amount_of_cores}"
   ami = "${var.test_core_ami}"
   instance_type = "${var.core_instance_type}"
   key_name = "${aws_key_pair.default.id}"
   user_data = <<-EOF
   #!/usr/bin/env bash
   sudo rm -rf /data/postgresql
   sudo rm -rf /data/stellar-core/buckets
   sudo docker-compose -f /data/docker-compose.yml up -d stellar-core-db
   sleep 14
   sudo docker-compose -f /data/docker-compose.yml run --rm stellar-core --newdb
   sleep 2
   sudo docker-compose -f /data/docker-compose.yml run --rm stellar-core --forcescp
   sleep 2
   sudo docker-compose -f /data/docker-compose.yml run --rm stellar-core --newhist local
   sleep 2
   sudo docker-compose -f /data/docker-compose.yml up -d
   EOF
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "8"
    volume_type = "standard"
  }

  tags = {
    Environment = "${var.SUFFIX}"
    Created = "${local.timestamp_sanitized}"
    Name = "test-core-${count.index}-${var.SUFFIX}"
  }
}
//todo: attach EBS from snapshot

######################
#  Watcher Core      #
#####################
resource "aws_instance" "test-watcher-core-1" {
   ami = "${var.test_watcher_core_1_ami}"
   instance_type = "${var.watcher_instance_type}"
   key_name = "${aws_key_pair.default.id}"
   user_data = <<-EOF
   #!/usr/bin/env bash
   sudo rm -rf /data/postgresql
   sudo rm -rf /data/stellar-core/buckets
   sudo docker-compose -f /data/docker-compose.yml up -d stellar-core-db
   sleep 14
   sudo docker-compose -f /data/docker-compose.yml run --rm stellar-core --newdb
   sleep 2
   sudo docker-compose -f /data/docker-compose.yml run --rm stellar-core --forcescp
   sleep 2
   sudo docker-compose -f /data/docker-compose.yml run --rm stellar-core --newhist$
   sleep 2
   sudo docker-compose -f /data/docker-compose.yml up -d
   EOF
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.stellar-sg.id}"]
   associate_public_ip_address = false
   source_dest_check = false
   #iam_instance_profile = "${aws_iam_instance_profile.stellar_profile.name}"
root_block_device {
    volume_size = "8"
    volume_type = "standard"
  }

  tags = {
    Environment = "${var.SUFFIX}"
    Created = "${local.timestamp_sanitized}"
    Name = "test-watcher-core-1-${var.SUFFIX}"
  }
}



###########################
# Define Stellar-tests NLB#
###########################
resource "aws_lb" "node1-nlb" {
  name               = "node1-nlb-${var.SUFFIX}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private-subnet.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "${var.SUFFIX}"
    Created = "${local.timestamp_sanitized}"
    Environment = "production"
  }
}

resource "aws_lb_listener" "stellar1_front_end" {
  load_balancer_arn = "${aws_lb.node1-nlb.arn}"
  port              = "11625"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.node1-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "node1-nlb-tg" {
  name     = "node1-nlb-tg-${var.SUFFIX}"
  port     = 11625
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = "${aws_lb_target_group.node1-nlb-tg.arn}"
  target_id        = "${aws_instance.test-core-1.id}"
  port             = 11625
}
#####################
# Define Stellar-2 NLB #
######################
resource "aws_lb" "node2-nlb" {
  name               = "node2-nlb-${var.SUFFIX}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private-subnet.id}"]

  enable_deletion_protection = false

  tags = {
        //todo: extract env name to variable, use cross wide in all machines tags

    Environment = "production"
  }
}

resource "aws_lb_listener" "stellar2_front_end" {
  load_balancer_arn = "${aws_lb.node2-nlb.arn}"
  port              = "11625"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.node2-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "node2-nlb-tg" {
  name     = "node2-nlb-tg-${var.SUFFIX}"
  port     = 11625
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = "${aws_lb_target_group.node2-nlb-tg.arn}"
  target_id        = "${aws_instance.test-core-2.id}"
  port             = 11625
}
########################
# Define Stellar 3 NLB #
########################
resource "aws_lb" "node3-nlb" {
  name               = "node3-nlb-${var.SUFFIX}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private-subnet.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "stellar3_front_end" {
  load_balancer_arn = "${aws_lb.node3-nlb.arn}"
  port              = "11625"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.node3-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "node3-nlb-tg" {
  name     = "node3-nlb-tg-${var.SUFFIX}"
  port     = 11625
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "attach3" {
  target_group_arn = "${aws_lb_target_group.node3-nlb-tg.arn}"
  target_id        = "${aws_instance.test-core-3.id}"
  port             = 11625
}
#####################
# Define Stellar-4 NLB #
######################
resource "aws_lb" "node4-nlb" {
  name               = "node4-nlb-${var.SUFFIX}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private-subnet.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "stellar4_front_end" {
  load_balancer_arn = "${aws_lb.node4-nlb.arn}"
  port              = "11625"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.node4-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "node4-nlb-tg" {
  name     = "node4-nlb-tg-${var.SUFFIX}"
  port     = 11625
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "attach4" {
  target_group_arn = "${aws_lb_target_group.node4-nlb-tg.arn}"
  target_id        = "${aws_instance.test-core-4.id}"
  port             = 11625
}

#####################
# Define Stellar 5 NLB #
######################
resource "aws_lb" "node5-nlb" {
  name               = "node5-nlb-${var.SUFFIX}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private-subnet.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "stellar5_front_end" {
  load_balancer_arn = "${aws_lb.node5-nlb.arn}"
  port              = "11625"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.node5-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "node5-nlb-tg" {
  name     = "node5-nlb-tg-${var.SUFFIX}"
  port     = 11625
  protocol = "TCP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "attach5" {
  target_group_arn = "${aws_lb_target_group.node5-nlb-tg.arn}"
  target_id        = "${aws_instance.test-core-5.id}"
  port             = 11625
}


#########################
# Define Prometheus ALB #
#########################
resource "aws_lb" "prometheus-nlb" {
  name               = "prometheus-alb-${var.SUFFIX}"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet-b.id}"]
  security_groups    = ["${aws_security_group.stellar-sg.id}"]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "prometheus_front_end" {
  load_balancer_arn = "${aws_lb.prometheus-nlb.arn}"
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.prometheus-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "prometheus-nlb-tg" {
  name     = "prometheus-alb-tg-${var.SUFFIX}"
  port     = 9090
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "${aws_vpc.Application-VPC.id}"
}

resource "aws_lb_target_group_attachment" "prometheus-attach" {
  target_group_arn = "${aws_lb_target_group.prometheus-nlb-tg.arn}"
  target_id        = "${aws_instance.prometheus_server.id}"
  port             = 9090
}
