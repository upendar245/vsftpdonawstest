resource "aws_security_group" "appsg" {
  name        = "appsg"
  description = "allow ssh from bastion host"
  vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.allow_ssh_public.id}", ]
    description     = " allow ssh traffic from bastion host "
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.allow_web_public.id}", ]
    description     = " allow web traffice from elb  "
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



locals {
  instance-userdata = <<EOF
#!/bin/bash
sleep 120
yum update -y   >> /var/log/bootstrap.log
yum install httpd -y >> /var/log/bootstrap.log
yum install vsftpd -y >> /var/log/bootstrap.log
chkconfig vsftpd on >> /var/log/bootstrap.log
service vsftpd start  >> /var/log/bootstrap.log
chkconfig httpd on >> /var/log/bootstrap.log
service httpd start >> /var/log/bootstrap.log
echo "hello world " >> /var/www/html/index.html

EOF


}

resource "aws_instance" "appinstance1" {
  ami                         = "ami-0756fbca465a59a30"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.pri1.id}"
  vpc_security_group_ids      = ["${aws_security_group.appsg.id}"]
  associate_public_ip_address = false
  key_name                    = "awsla"
  user_data_base64            = "${base64encode(local.instance-userdata)}"
  tags = {
    Name = "app Instance 1 "
  }
}

resource "aws_instance" "appinstance2" {
  ami                         = "ami-0756fbca465a59a30"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.pri2.id}"
  vpc_security_group_ids      = ["${aws_security_group.appsg.id}"]
  associate_public_ip_address = false
  key_name                    = "awsla"
  user_data_base64            = "${base64encode(local.instance-userdata)}"
  tags = {
    Name = "app Instance2"
  }
}
