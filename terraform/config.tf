# ----------------------------------------------------------------------------------------------------------------------
# State & Providers
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  backend "s3" {
    key      = "cz-dev/terraform.tfstate"
    encrypt  = true
    bucket   = "cz-terraform-state"
    region   = "us-west-2"
  }

  required_providers {
    random = {
      source = "hashicorp/random"
      version = "~> 3"
    }

    null = {
      source = "hashicorp/null"
      version = "~> 3"
    }

    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }

    tls = {
      source = "hashicorp/tls"
      version = "~> 4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------

### EKS Cluster Variables

variable "kubernetes_version" { default = "1.29" }
variable "eks_instance_types" { default = ["t3.small"] }
variable "eks_disk_size"      { default = 100 }
variable "eks_node_size"      { default = 1 }
variable "eks_access"         { default = [] }
variable "prefix"             {  }

### User Variables
variable "user" {
  type    = map
  default = {
    /*
    ssh_key       = "<public key>"
    instance_type = "t2.micro"
    volume_size   = 500
    */
  }
}

### VPC Variables

variable "vpc_cidr_block" {
  type    = string
}

variable "subnet_count" {
  type    = number
  default = 3
}

variable "zone_count" {
  type    = number
  default = 2
}

variable "aws_region" {
  default = "us-west-2"
  type    = string
}

### App Variables

# ----------------------------------------------------------------------------------------------------------------------
# Locals
# ----------------------------------------------------------------------------------------------------------------------

locals {
  ecr_repositories = []
  
  cidr_blocks = {
    app = slice(module.vpc.prv_cidr_blocks, 0, var.zone_count)
    rds = slice(module.vpc.prv_cidr_blocks, var.zone_count, var.zone_count * 2)
    pub = module.vpc.pub_cidr_blocks
  }

  subnet_ids = {
    app = slice(module.vpc.prv_subnet_ids, 0, var.zone_count)
    rds = slice(module.vpc.prv_subnet_ids, var.zone_count, var.zone_count * 2)
    pub = module.vpc.pub_subnet_ids
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# AMI Map
# ----------------------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    values = ["${var.prefix}-*"]
    name   = "name"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------------------------------------------------

output "admin_ip_address" {
  value = aws_eip.ip.public_ip
}

output "cidr_blocks" {
  value = local.cidr_blocks
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
