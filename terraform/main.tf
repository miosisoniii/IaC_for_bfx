## PROVIDER -------------------------------------------------------------
# - using AWS as my provider
# - deploying in us-west-1 region

provider "aws" {
  region = "us-west-1" # using this because I am located in Denver
}

## RESOURCE: RSA public key ---------------------------------------------
# - I am using the one I have linked to github in the filepath below

resource "aws_key_pair" "my_keypair" {
  key_name   = "my-keypair"
  public_key = file("~/.ssh/id_rsa.pub") # Point this to your public key
}

## RESOURCE: Create Docker instance -------------------------------------
# - This resource installs Docker on the EC2 instance, which will end up installing and running the analysis script
resource "aws_instance" "docker_instance" {
  ami             = "ami-06d2c6c1b5cbaee5f"  # Amazon Linux 2 LTS AMI; update if needed
  instance_type   = "t2.micro"

  key_name        = aws_key_pair.my_keypair.key_name
  security_groups = [aws_security_group.docker_sg.name]

  tags = {
    Name = "Docker-EC2"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user
              EOF
}


## RESOURCE: Security Group for Docker --------------------------------
# This allows receive traffic from specific ports on the instance.
# CIDR blocks specify IP address ranges
# - allows incoming requests on port 0, 22, from any IP with "0.0.0.0/0"

resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "Docker Security Group"

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
