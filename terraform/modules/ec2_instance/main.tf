# --------------------------------------------------------------------------------
# Security Groups
# --------------------------------------------------------------------------------

resource "aws_security_group" "group" {
  vpc_id = var.vpc_id

  dynamic ingress {
    for_each = var.cidr_ingress_rules

    content {
      cidr_blocks = ingress.value.cidr_blocks
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
    }
  }

  dynamic egress {
    for_each = var.egress_rules

    content {
      cidr_blocks = egress.value.cidr_blocks
      protocol    = egress.value.protocol
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
    }
  }

  tags = merge(
    { Name = var.identifier },
    var.tags
  )
}

# --------------------------------------------------------------------------------
# EC2 Instances
# --------------------------------------------------------------------------------

resource "aws_instance" "ec2" {
  disable_api_termination = var.protected
  iam_instance_profile    = var.iam_instance_profile
  source_dest_check       = var.source_dest_check
  ebs_optimized           = var.ebs_optimized
  instance_type           = var.instance_type
  monitoring              = var.monitoring
  subnet_id               = element(var.vpc_subnet_ids, count.index)
  user_data               = var.user_data
  key_name                = var.key_name
  count                   = var.number
  ami                     = var.ami

  vpc_security_group_ids = [
    aws_security_group.group.id
  ]

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = merge(
    tomap({
      "Name" = var.identifier
    }),
    var.tags
  )
}
