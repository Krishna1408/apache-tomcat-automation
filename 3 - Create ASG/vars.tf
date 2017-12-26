

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "aws_region" {
    default = "ap-southeast-2"
}

variable "filter_ami" {
    default = "apache-tomcat-0.1"
}

variable "subnet_tag_name" {
    default = "Name"
}

variable "subnet_tag_value" {
    default = "public_subnet"
}

variable "instance_type" {
    default = "t2.small"
}

variable "port_22_cidr" {
    description = "CIDR for the whole VPC"
    default = "203.13.146.0/24"
}

variable "max_instance_asg" {
    default = "5"
}

