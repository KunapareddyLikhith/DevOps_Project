terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "default" {
  default = true
}



resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "main_server" {
  ami                    = "ami-0a14f53a6fe4dfcd1"  # replace with valid ap-south-1 AMI if needed
  instance_type          = "t3.micro"
  key_name               = "likth"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "main_server"
  }
}



resource "null_resource" "install_docker" {

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.main_server.public_ip
    private_key = file("../likth.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu"
    ]
  }
}