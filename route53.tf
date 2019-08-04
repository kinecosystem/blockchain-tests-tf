resource "aws_route53_zone" "primary" {
  name = "test.kin"

  vpc {
    vpc_id = "${aws_vpc.Application-VPC.id}"
  }
}

#resource "aws_route53_zone_association" "secondary" {
#  zone_id = "${aws_route53_zone.private.zone_id}"
#  vpc_id  = "${aws_vpc.Application-VPC.id}"
#

resource "aws_route53_record" "ip-watcher-test-1" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-watcher-test-1"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-watcher-core-1.private_ip}"]
}

resource "aws_route53_record" "ip-horizon-test-1" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-horizon-test-1"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-horizon-1.private_ip}"]
}

resource "aws_route53_record" "ip-test-core-1" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-core-test-1"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-core-1.private_ip}"]
}

resource "aws_route53_record" "ip-test-core-2" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-core-test-2"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-core-2.private_ip}"]
}

resource "aws_route53_record" "ip-test-core-3" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-core-test-3"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-core-3.private_ip}"]
}

resource "aws_route53_record" "ip-test-core-4" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-core-test-4"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-core-4.private_ip}"]
}

resource "aws_route53_record" "ip-test-core-5" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "ip-core-test-5"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test-core-5.private_ip}"]
}



resource "aws_route53_record" "prometheus-record" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "prometheus"
  type    = "A"
 alias {
    name                   = "${aws_lb.prometheus-nlb.dns_name}"
    zone_id                = "${aws_lb.prometheus-nlb.zone_id}"
    evaluate_target_health = false
  }
}


#resource "aws_lb" "node1-nlb" 


resource "aws_route53_record" "test-core-1" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "core-test-1"
  type    = "A" 
 alias {
    name                   = "${aws_lb.node1-nlb.dns_name}"
    zone_id                = "${aws_lb.node1-nlb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "test-core-2" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "core-test-2"
  type    = "A"
  alias {
    name                   = "${aws_lb.node2-nlb.dns_name}"
    zone_id                = "${aws_lb.node2-nlb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "test-core-3" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "core-test-3"
  type    = "A"
 alias {
    name                   = "${aws_lb.node3-nlb.dns_name}"
    zone_id                = "${aws_lb.node3-nlb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "test-core-4" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "core-test-4"
  type    = "A"
 alias {
    name                   = "${aws_lb.node4-nlb.dns_name}"
    zone_id                = "${aws_lb.node4-nlb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "test-core-5" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "core-test-5"
  type    = "A"
 alias {
    name                   = "${aws_lb.node5-nlb.dns_name}"
    zone_id                = "${aws_lb.node5-nlb.zone_id}"
    evaluate_target_health = false
  }
}
