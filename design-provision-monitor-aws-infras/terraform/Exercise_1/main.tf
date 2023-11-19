# Designate a cloud provider, region, and credentials
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "udacity"
  region  = "us-east-1"
}


# provision 4 AWS t2.micro EC2 instances named Udacity T2

locals {
  public_subnet_id = "subnet-0f2cdcde74c3fc239"
  resource_tag = "udacity-terraform"
}

resource "aws_instance" "t2_instances" {
  count         = 4
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.micro"
  subnet_id     = local.public_subnet_id
  tags = {
    "Group"   = local.resource_tag
    "Name"    = "Udacity T2"
  }
}


# provision 2 m4.large EC2 instances named Udacity M4

# resource "aws_instance" "m4_instances" {
#  count         = 2
#  ami           = "ami-0230bd60aa48260c6"
#  instance_type = "m4.large"
#  subnet_id     = local.public_subnet_id
#  tags = {
#    "Group"   = local.resource_tag
#    "Name"    = "Udacity M4"
#  }
#}
