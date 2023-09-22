# Ex01 

## Set Provider (AWS)
provider "aws" {
    region = "us-west-1"
}

## Set AWS key pair
resource "aws_key_pair" "my_key_pair" {
    key_name = "my-keypair"
    public_key = file("~/.ssh/id_rsa.pub")
}


## Push 5 instances

## But first only create one instance
source "aws_instance" "ec2-instance1" {
  ami             = "ami-06d2c6c1b5cbaee5f"  # Amazon Linux 2 LTS AMI; update if needed
  instance_type   = "t2.micro"

  key_name        = aws_key_pair.my_keypair.key_name

  tags = {
    Name = "Ex1-EC2-instance1"
  }

# use bash to display "hello world" on boot
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, world!" > index.html
              nohup busybox httpd -f -p 8080 &  # use busybox to 
              EOF
}



## Refactor code using loops until matching what is already deployed in AWS
