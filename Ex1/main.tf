## Example 1

# Push out 5  instances all written as separate resources

## define provider
provider "aws" {
    region = "us-west-1"
}

## create variable for SSH port
variable "ssh_port" {
    description = "Port for SSH"
    type = number
    default = 22
}

## create Server Port Variable
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

## Create key_pair
resource "aws_key_pair" "ssh_key_pair" {
    key_name = "ssh-key-pair"
    public_key = file("~/.ssh/id_rsa.pub")
}
 
## create security groups for the 5
resource "aws_security_group" "multi_instance_sg" {
    name = "multi-instance-sg"
    description = "Security group for all instances"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "multi-instance-sg"
    }
}


## The 5 instances as separate resources
resource "aws_instance" "instance1" {
    ami = "ami-0f8e81a3da6e2510a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.multi_instance_sg.id]
    
}

resource "aws_instance" "instance2" {
    ami = "ami-0f8e81a3da6e2510a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.multi_instance_sg.id]
}

resource "aws_instance" "instance3" {
    ami = "ami-0f8e81a3da6e2510a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.multi_instance_sg.id]
}

resource "aws_instance" "instance4" {
    ami = "ami-0f8e81a3da6e2510a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.multi_instance_sg.id]
}

resource "aws_instance" "instance5" {
    ami = "ami-0f8e81a3da6e2510a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.multi_instance_sg.id]
}

## success!




## Refactoring (using loops until matches what is already deployed above)

# creat a variable containing a list of strings to loop through
variable "instanceid" {
    description = "List of instance names"
    type = list(string)
    default = ["instance1", "instance2", "instance3", "instance4", "instance5"]
}


# Create resource with instance id's
resource "aws_instance" "multiinstance"{
    count = length(var.instanceid)

    ami = "ami-0f8e81a3da6e2510a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.multi_instance_sg.id]

    tags = {
        Name = var.instanceid[count.index]
    }
}
