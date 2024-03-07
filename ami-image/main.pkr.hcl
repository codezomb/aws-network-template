packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "prefix" {
  type = string
}

variable "ami" {
  type    = string
  default = "ami-073ff6027d02b1312"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "amd64" {
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  source_ami    = var.ami
  ami_name      = "${var.prefix}-${local.timestamp}"
  region        = "us-west-2"

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 128
    volume_type           = "gp3"
  }

  ami_regions = [
    "us-west-2"
  ]
}

build {
  provisioner "shell" {
    execute_command = "sudo bash '{{ .Path }}'"
    scripts         = ["./00_bootstrap.sh"]
  }

  provisioner "shell" {
    execute_command = "sudo bash '{{ .Path }}'"
    scripts         = ["./01_setup.sh"]
  }

  sources = [
    "source.amazon-ebs.amd64"
  ]
}
