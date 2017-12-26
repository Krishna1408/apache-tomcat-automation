/*
This terraform script will create a VPC and perform the following actions
1) Create Internet Gateway for public subnets
2) Create Public Subnets in multiple AZs and update route rules to use Internet Gateway
3) Create a NAT gateway service in a single AZ to be associated with
4) Create Private Subnets and update route rules to use NAT Gateway service
*/

/*
Create a VPC and setup an AWS Internet Gateway
*/

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "kris-test-vpc"
    }
}

data "aws_availability_zones" "apache" {}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

/*
 Setup public Subnets
*/
resource "aws_subnet" "zone-a-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr_a}"
    availability_zone = "${data.aws_availability_zones.apache.names[0]}"

    tags {
        Name = "public_subneta"
    }
}

resource "aws_subnet" "zone-b-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr_b}"
    availability_zone = "${data.aws_availability_zones.apache.names[1]}"

    tags {
        Name = "public_subnetb"
    }
}

resource "aws_subnet" "zone-c-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr_c}"
    availability_zone = "${data.aws_availability_zones.apache.names[2]}"

    tags {
        Name = "public_subnetc"
    }
}

/* Public Subnet Route Rules
*/
resource "aws_route_table" "zone-a-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "route_public_subneta"
    }
}

resource "aws_route_table_association" "zone-a-public" {
    subnet_id = "${aws_subnet.zone-a-public.id}"
    route_table_id = "${aws_route_table.zone-a-public.id}"
}

resource "aws_route_table" "zone-b-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "route_public_subnetb"
    }
}

resource "aws_route_table_association" "zone-b-public" {
    subnet_id = "${aws_subnet.zone-b-public.id}"
    route_table_id = "${aws_route_table.zone-b-public.id}"
}

resource "aws_route_table" "zone-c-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "route_public_subnetc"
    }
}

resource "aws_route_table_association" "zone-c-public" {
    subnet_id = "${aws_subnet.zone-c-public.id}"
    route_table_id = "${aws_route_table.zone-c-public.id}"
}

/*
AWS NAT Gateway Setup in a Public Subnet
*/

resource "aws_eip" "natEIP" {
    vpc      = true
}

resource "aws_nat_gateway" "nat_gateway_public" {
    allocation_id = "${aws_eip.natEIP.id}"
    subnet_id = "${aws_subnet.zone-b-public.id}"
    depends_on = ["aws_internet_gateway.default"]
}


/*
 Private Subnet setup
*/

resource "aws_subnet" "zone-a-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr_a}"
    availability_zone = "${data.aws_availability_zones.apache.names[0]}"

    tags {
        Name = "Private Subnet Zone A"
    }
}

resource "aws_subnet" "zone-b-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr_b}"
    availability_zone = "${data.aws_availability_zones.apache.names[1]}"

    tags {
        Name = "Private Subnet Zone B"
    }
}

resource "aws_subnet" "zone-c-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr_c}"
    availability_zone = "${data.aws_availability_zones.apache.names[2]}"

    tags {
        Name = "Private Subnet Zone C"
    }
}

/*
 Private Subnet Route Rules to be routed to NAT gateway
*/

resource "aws_route_table" "zone-a-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway_public.id}"
 }

    tags {
        Name = "Private Subnet A"
    }
}

resource "aws_route_table_association" "zone-a-private" {
    subnet_id = "${aws_subnet.zone-a-private.id}"
    route_table_id = "${aws_route_table.zone-a-private.id}"
}


resource "aws_route_table" "zone-b-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway_public.id}"
  }

    tags {
        Name = "Private Subnet B"
    }
}

resource "aws_route_table_association" "zone-b-private" {
    subnet_id = "${aws_subnet.zone-b-private.id}"
    route_table_id = "${aws_route_table.zone-b-private.id}"
}

resource "aws_route_table" "zone-c-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway_public.id}"
    }

    tags {
        Name = "Private Subnet C"
    }
}

resource "aws_route_table_association" "zone-c-private" {
    subnet_id = "${aws_subnet.zone-c-private.id}"
    route_table_id = "${aws_route_table.zone-c-private.id}"
}