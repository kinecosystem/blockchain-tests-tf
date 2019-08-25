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

#########################
# Define Horizon    ALB #
#########################
resource "aws_lb" "horizon-nlb" {
  name               = "horizon-alb-${var.SUFFIX}"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-00d0cd82faf60438e", "subnet-c06ff9a7"]
  security_groups    = ["sg-0edd1ca48b57dc309"]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "horizon_front_end" {
  load_balancer_arn = "${aws_lb.horizon-nlb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.horizon-nlb-tg.arn}"
  }
}


resource "aws_lb_target_group" "horizon-nlb-tg" {
  name     = "horizon-alb-tg-${var.SUFFIX}"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = "${var.vpcdeploy}"
}

resource "aws_lb_target_group_attachment" "horizon-attach" {
  target_group_arn = "${aws_lb_target_group.horizon-nlb-tg.arn}"
  target_id        = "${aws_instance.horizon-test-fed.id}"
  port             = 80
}
