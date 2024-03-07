# ------------------------------------------------------------------------------------
# EC2 Instance
# ------------------------------------------------------------------------------------

module "admin-server" {
  source               = "./modules/ec2_instance"
  iam_instance_profile = aws_iam_instance_profile.admin.id
  vpc_subnet_ids       = module.vpc.pub_subnet_ids
  instance_type        = var.user.instance_type
  volume_size          = 128
  monitoring           = false
  identifier           = "${var.prefix}-admin-instance"
  vpc_id               = module.vpc.vpc_id
  ami                  = data.aws_ami.ami.image_id

  user_data = templatefile("./scripts/user_data.sh", {
    account = data.aws_caller_identity.current.account_id
    ssh_key = var.user.ssh_key
  })

  cidr_ingress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "TCP"
      from_port   = 8443
      to_port     = 8443
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "TCP"
      from_port   = 22
      to_port     = 22
    }
  ]

  egress_rules = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
    }
  ]

  depends_on = [
    aws_ebs_volume.volume
  ]
}

# ------------------------------------------------------------------------------------
# EBS Volume
# ------------------------------------------------------------------------------------

resource "aws_volume_attachment" "attachment" {
  device_name = "/dev/sdh"
  instance_id = module.admin-server.instance_ids[0]
  volume_id   = aws_ebs_volume.volume.id
}

resource "aws_ebs_volume" "volume" {
  availability_zone = "${var.aws_region}a"
  size              = var.user.volume_size
  type              = "gp3"

  tags = {
    Name = "${var.prefix}-admin-instance"
  }
}

# ------------------------------------------------------------------------------------
# Elastic IP
# ------------------------------------------------------------------------------------

resource "aws_eip" "ip" {
  instance = module.admin-server.instance_ids[0]
  domain   = "vpc"
}

# ------------------------------------------------------------------------------------
# Provisioners
# ------------------------------------------------------------------------------------

resource "null_resource" "tags" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = <<-EOT
    aws --region us-west-2 ec2 create-tags \
      --resources ${join(" ", module.admin-server.instance_ids)} \
      --tags \
        Key=Name,Value=${var.prefix}-admin-instance
    EOT
  }
}
