provider "aws" {
  region = "us-east-1"
}
# creating VPC 
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "main"
  }
}
# creating gw and attaching it to vpc 
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "main"
  }
}
# creating public subnet 1 
resource "aws_subnet" "pub1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub1"
  }
}
# creating public subnet 2 
resource "aws_subnet" "pub2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "pub2"
  }
}

# creating private subnet 1
resource "aws_subnet" "pri1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pri1"
  }
}

# creating private subnet 2
resource "aws_subnet" "pri2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "pri2"
  }
}

# creating public route table (igw attached)
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "public"
  }
}

#creating eip to allocate it to NAT gateway
resource "aws_eip" "natgw-ip" {
  vpc = true
  tags = {
    Name = "nateip"
  }

}


# creating NAT gatway 
resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.natgw-ip.id}"
  subnet_id     = "${aws_subnet.pub1.id}"
}


# creating  internet access route table using internet gateway
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw.id}"
  }
  tags = {
    Name = "NAT route "
  }
}
# updating route tables for public subnets 
resource "aws_route_table_association" "publcaccess" {
  subnet_id      = "${aws_subnet.pub1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "publcaccess2" {
  subnet_id      = "${aws_subnet.pub2.id}"
  route_table_id = "${aws_route_table.public.id}"
}
# updating route tables for private subnets 
resource "aws_route_table_association" "privateaccess1" {
  subnet_id      = "${aws_subnet.pri1.id}"
  route_table_id = "${aws_route_table.private.id}"
}
# adding route tables 
resource "aws_route_table_association" "privateaccess2" {
  subnet_id      = "${aws_subnet.pri2.id}"
  route_table_id = "${aws_route_table.private.id}"
}

# Adding securuty groups 
resource "aws_security_group" "allow_ssh_public" {
  name        = "allow_ssh_world"
  description = "allow ssh traffic to pubic"
  vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Adding securuty groups 
resource "aws_security_group" "allow_web_public" {
  name        = "allow_web_world"
  description = "allow web traffic to pubic"
  vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = " allow web traffic"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



