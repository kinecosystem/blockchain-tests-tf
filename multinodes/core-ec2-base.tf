###########################
# EC2 Prometheus Server   #
###########################
resource "aws_instance" "prometheus_server" {
   ami = "${var.prometheus}"
   user_data = "${file("nodes/prometheus-env")}"
   instance_type = "t3.medium"
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
    Name = "Promehteus-Server-${var.SUFFIX}"
  }
}
############################


###################################
# EC2 stellar-load-testing client #
##################################
resource "aws_instance" "test-load-client-1" {
   ami = "${var.test_load_client_ami}"
   instance_type = "t3.medium"
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
    Name = "test-load-client-1-${var.SUFFIX}"
  }
}


##################
# EC2 Horizon  ##
#################
resource "aws_instance" "test-horizon-1" {
   ami = "${var.horizon_1_ami}"
   instance_type = "c5.large"
   key_name = "${aws_key_pair.default.id}"
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
    Name = "test-horizon-1-${var.SUFFIX}"
  }
}






######################
#  Watcher Core      #
#####################
resource "aws_instance" "test-watcher-core-1" {
   ami = "${var.test_watcher_core_1_ami}"
   instance_type = "c5.large"
   key_name = "${aws_key_pair.default.id}"
   user_data = "${file("nodes/setup-env.watcher")}"
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
    Name = "test-watcher-core-1-${var.SUFFIX}"
  }
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
