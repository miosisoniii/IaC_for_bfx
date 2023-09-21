# IaC_for_bfx 🏗️

## Using Terraform IaC to Set Up an RNA-Seq Bioinformatics Workflow

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

Let's dive into the `main.tf` file and see what makes this Terraform script tick.

```
provider "aws" {
  region = "us-west-1" 
}

```




## Versions/Session Info 💻

- OS: iOS Ventura v13.5.2
- aws-cli: v2.13.9
- terraform: v1.5.7 on `darwin_arm64`
- VScode: v1.82.2
- git: v2.42.0
