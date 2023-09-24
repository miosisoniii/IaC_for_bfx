# Ex01 

# Show Public IP in Output Variable
output "public_ip" {
  value = aws_instance.web_server_instance.public_ip
  description = "The public IP address of the web server"
}

# Server Port Variable
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default  = 8080
}

# SSH Port Variable
variable "ssh_port" {
  description = "The port the server will use for SSH requests"
  type        = number
  default = 22
}


# AWS Provider Configuration
provider "aws" {
  region = "us-west-1"
}

# Create AWS Key Pair for SSH
resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "ssh-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create Security Group with Ingress Rules for Ports 8080 and 22
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Security group for web server"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Caution: This allows SSH from any IP
  }

  tags = {
    Name = "web-server-sg"
  }
}

# Create an AWS EC2 Instance
resource "aws_instance" "web_server_instance" {
  ami           = "ami-0f8e81a3da6e2510a" # Ubuntu 22.04 LTS (HVM) SSD 
  instance_type = "t2.micro"

  key_name               = aws_key_pair.ssh_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  tags = {
    Name = "web-server-instance"
  }

  # User Data to Run a Simple Web Server
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, world!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &  
              EOF

  # Re-create instance if user_data changes
  user_data_replace_on_change = true
}
