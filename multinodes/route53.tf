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

