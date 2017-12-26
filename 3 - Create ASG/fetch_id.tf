data "aws_ami" "apache" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "tag:Name"
    values = ["${var.filter_ami}"]
  }
}

data "aws_subnet" "public_a" {

  filter {
    name = "tag:${var.subnet_tag_name}"
    values = ["${var.subnet_tag_value}a"]
  }

}

data "aws_subnet" "public_b" {

  filter {
    name = "tag:${var.subnet_tag_name}"
    values = ["${var.subnet_tag_value}b"]
  }

}

data "aws_subnet" "public_c" {

  filter {
    name = "tag:${var.subnet_tag_name}"
    values = ["${var.subnet_tag_value}c"]
  }

}

data "aws_availability_zones" "apache" {}
