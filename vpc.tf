# Define our VPC
resource "aws_vpc" "padma-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "padma-vpc"
  }
}

# Define the public subnet
resource "aws_subnet" "padma-public-subnet" {
  vpc_id = "${aws_vpc.padma-vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "padma-Web Public Subnet"
  }
}

# Define the private subnet
resource "aws_subnet" "padma-private-subnet" {
  vpc_id = "${aws_vpc.padma-vpc.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "padma-Private Subnet"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "padma-gw" {
  vpc_id = "${aws_vpc.padma-vpc.id}"

  tags {
    Name = "padma-VPC IGW"
  }
}
# Define the route table
resource "aws_route_table" "padma-web-public-rt" {
  vpc_id = "${aws_vpc.padma-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.padma-gw.id}"
  }

  tags {
    Name = "padma-Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "padma-web-public-rt-asso" {
  subnet_id = "${aws_subnet.padma-public-subnet.id}"
  route_table_id = "${aws_route_table.padma-web-public-rt.id}"
}
# Define the security group for public subnet
resource "aws_security_group" "padma-sgweb" {
  name = "padma_vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.padma-vpc.id}"

  tags {
    Name = "Web Server SG"
  }
}
# Define the security group for private subnet
resource "aws_security_group" "padma_sgdb"{
  name = "padma_sg_test_db"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  vpc_id = "${aws_vpc.padma-vpc.id}"

  tags {
    Name = "DB SG"
  }
}
