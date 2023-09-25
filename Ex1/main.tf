# Ex01 

# Show Public IP in Output Variable
# output "public_ip" {
  # value       = aws_instance.web_server_instance.public_ip
  # description = "The public IP address of the web server"
# }

# Server Port Variable
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

# SSH Port Variable
variable "ssh_port" {
  description = "The port the server will use for SSH requests"
  type        = number
  default     = 22
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

# Create an AWS EC2 Instance/AWS launch configuration
resource "aws_launch_configuration" "web_server_asg" {
  # Creating single AWS EC2 Instance 
  # resource "aws_instance" "web_server_instance" {
  # 'ami' arg used in SINGLE AWS EC2 instance
  # ami           = "ami-0f8e81a3da6e2510a" # Ubuntu 22.04 LTS (HVM) SSD 
  # must use 'image_id' for AWS Launch config
  image_id = "ami-0f8e81a3da6e2510a"
  instance_type = "t2.micro"

  key_name = aws_key_pair.ssh_key_pair.key_name
  # For single AMI
  # vpc_security_group_ids = [aws_security_group.web_server_instance.id]
  # Security Group change for ASG
  security_groups = [aws_security_group.web_server_sg.id]

  # tags not used in ASG
  # tags = {
  # Name = "web-server-instance"
  # }

  # User Data to Run a Simple Web Server
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, world!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &  
              EOF

  # Re-create instance if user_data changes
  # user_data_replace_on_change = true # not needed in ASG

  # Set Lifecyle - required for launch config with ASG
  lifecycle {
    create_before_destroy = true
  }

}

# Create Auto Scaling Group 
resource "aws_autoscaling_group" "web_server_asg" {
  launch_configuration = aws_launch_configuration.web_server_asg.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  # point at new target group
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

# Create Data Source for VPC
data "aws_vpc" "default" {
  default = true
}

# Create Data source for AWS subnets
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create Application Load Balancer, suited for load balancing of HTTP and HTTPS traffic
resource "aws_lb" "web_server_asg" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids

  # call new ALB Security Group
  security_groups = [aws_security_group.alb.id]
}

# Define a Listener for the above ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_server_asg.arn
  port = 80
  protocol = "HTTP"

  # By default, return a 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

# Create AWS Security Group for the Load Balancer/ALB
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"

  # allow INbound HTTP requests
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow ALL OUTbound requests
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create TARGET GROUP for ASG resource
resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

# Create Listener Rule 
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# Must replace public_ip of the single EC2 instance with output showing DNS of ALB
output "alb_dns_name" {
  value = aws_lb.web_server_asg.dns_name
  description = "The domain name of the load balancer"
}