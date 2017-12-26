

resource "aws_elb" "apachelb" {
  name = "apache-elb"

  subnets = ["${data.aws_subnet.public_a.id}","${data.aws_subnet.public_b.id}","${data.aws_subnet.public_c.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    interval = 10
    target = "TCP:80"
    timeout = 3
    unhealthy_threshold = 3
  }
  connection_draining = true
}