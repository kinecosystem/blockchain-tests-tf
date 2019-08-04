output "aws_eip_natip" {
  value = "${aws_eip.nat.public_ip}"
  description = "The NAT IP address of the Stellar Subnet for Whitelisting"
}

output "aws_test_client_ip" {
  value = "${aws_instance.test-load-client-1.private_ip}"
  description = "The Private IP address of Test-Client"
}


output "aws_prom_dns" {
  value = "${aws_lb.prometheus-nlb.dns_name}"
  description = "The address of Prometheus NLB"
}

output "aws_prod_peer" {
  value = "${aws_vpc_peering_connection.jenkinstocore.id}"
  description = "Peering connection of Production to update route table"
}

output "aws_mgmt_peer" {
  value = "${aws_vpc_peering_connection.mgmttocore.id}"
  description = "Peering connection of Production to update route table"
}

