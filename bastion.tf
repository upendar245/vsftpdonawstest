resource "aws_instance" "bastionhost" {
  ami                         = "ami-0756fbca465a59a30"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.pub1.id}"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh_public.id}"]
  associate_public_ip_address = true
  key_name                    = "awsla"
  tags = {
    Name = "bastion Instance"
  }
}
