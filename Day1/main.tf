provider "aws" {
  region = "eu-central-1"
  access_key = "Access Key Here"
  secret_key = "Secret Key Here"
}

resource "aws_security_group" "internship-sec-group" {
  vpc_id = "VPC Id here"
  name = "internship-info"
  description = "Security group for Internship resources"

  ingress {
    from_port = 22
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "test-instance" {
  ami = "ami-00f22f6155d6d92c5" // Latest CentOS x64 ami
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.internship-sec-group.id ]
  subnet_id = "Subnet Id here"

}