//
//output "ami_id" {
//  value = "${data.aws_ami.apache.id}"
//}
//
//
//output "subnet_ida" {
//  value = "${data.aws_subnet.public_a.id}"
//}
//
//
//output "subnet_idb" {
//  value = "${data.aws_subnet.public_b.id}"
//}
//
//
//output "subnet_idc" {
//  value = "${data.aws_subnet.public_c.id}"
//}

output "ELB address to hit on brower" {value = "${aws_elb.apachelb.dns_name}"}

