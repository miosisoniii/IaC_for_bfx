# IaC_for_bfx 🏗️

## Using Terraform IaC to Set Up an RNA-Seq Bioinformatics Compute Infrastructure

### Purpose
A quick project demonstrating knowledge of Terraform Infrastructure as Code (IaC), using AWS, Docker, a bit of Python, and RNA-seq Differential Expression R packages `HISAT2`, `StringTie`, and `Ballgown`. It also doesn't hurt to show my style of documentation. :) 

**TLDR:** Just demonstrating a full-stack bioinformatics pipeline from the computing infrastructure to the analysis pipeline.

This Repository is likely only going to cover the setup of the EC2 instance with all of the typical tools that are needed for the RNA-seq differential expression analysis. The actual analysis will (likely) continue in a separate repository in the future (to ensure that this project can remain cost-free).

## Setup 📚

#### Install required software
- Install [VScode](https://code.visualstudio.com/docs/introvideos/basics) to practice usage of this visual editor for Python, and its integration with Git.
- Install [git](https://git-scm.com/download/mac) to practice Version Control as it applies to IaC, but also general precaution.
- Install [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) to you know, terraform things (jk, its so that we can use IaC to set up the EC2 instance.
- Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) to enable IAM permissions and setup of AWS infrastructure.
- Install [Docker](https://docs.docker.com/desktop/install/mac-install/)

## Workflow

1. Create Terraform script  called `main.tf`

> Just a quick note for myself for **comments** in terraform code:
>
> 
> - `#` begins single-line comment ending at the **end** of the line
> - `//` begins single-line comment as **alternative** to `#`
> - `/*` and `*/` are start/end delimiters for comment spanning multiple lines.
> 
>
> Stick with the `#` since some auto-config formatting tools may automatically transform `//` into `#`.

Let's dive into the `main.tf` file and see what makes this Terraform script tick looking at the comments I left in the code. Using this [blog from gruntwork](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180#.p56muw3c0) to understand Terraform terminology.

```
## PROVIDER
# using AWS as my provider
# deploying into us-west-1 region

provider "aws" {
  region = "us-west-1" # using this because I am located in Denver
}

## RESOURCE: RSA public key
# I am using the one I have linked to github in the filepath below

resource "aws_key_pair" "my_keypair" {
  key_name   = "my-keypair"
  public_key = file("~/.ssh/id_rsa.pub") # Point this to your public key
}

## RESOURCE: Security Group for RStudio
# This allows receive traffic from specific ports on the instance.
# CIDR blocks specify IP address ranges
# - allows incoming requests on port 0, 22, and 8787 from any IP with "0.0.0.0/0"

resource "aws_security_group" "rstudio_sg" {
  name        = "rstudio-sg"
  description = "RStudio Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8787
    to_port     = 8787
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

## RESOURCE: t2.micro EC2 instance
# - Declare the AMI type
# - Declare the Instance type: t2.micro
# - Declare the keypair by calling from the resource above
# - Installs Rstudio Server

resource "aws_instance" "rstudio_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Update this to the latest Amazon Linux 2 LTS AMI
  instance_type = "t2.micro"

  key_name = aws_key_pair.my_keypair.key_name

  security_groups = [aws_security_group.rstudio_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install R3.4 -y
              sudo yum install -y rstudio-server
              EOF

  tags = {
    Name = "rstudio-instance"
  }
}

```

> Notice that in the `aws_instance` resource, that the `key_name` calls the above resource for the `key_pair` by name as:
> `aws_key_pair.my_keypair.key_name`. This is because the syntax is as follows: `<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>.


## Versions/Session Info 💻

- OS: iOS Ventura v13.5.2
- aws-cli: v2.13.9
- terraform: v1.5.7 on `darwin_arm64`
- VScode: v1.82.2
- git: v2.42.0
