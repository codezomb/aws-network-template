# ----------------------------------------------------------------------------------------------------------------------
# Lambda Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "lambda_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.lambda"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# ELB Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "elb_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# EBS Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ebs_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.ebs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# EC2 Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ec2_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# KMS Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "kms_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# SQS Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ses_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.email-smtp"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# VPC Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "sqs_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# S3 Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.prv_route_table_ids
  vpc_id            = module.vpc.vpc_id
}

# ----------------------------------------------------------------------------------------------------------------------
# SSM Endpoint
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "ssm_vpc_endpoint" {
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc.pub_subnet_ids
  vpc_id              = module.vpc.vpc_id

  security_group_ids = [
    data.aws_security_group.default.id
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Security Groups
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "endpoints" {
  security_group_id = data.aws_security_group.default.id
  from_port         = -1
  to_port           = -1
  type              = "ingress"
  protocol          = "all"

  cidr_blocks = [
    var.vpc_cidr_block
  ]
}

data "aws_security_group" "default" {
  filter {
    values = [module.vpc.vpc_id]
    name   = "vpc-id"
  }

  filter {
    values = ["default"]
    name   = "group-name"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# VPC
# ----------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "./modules/vpc_network"
  vpc_cidr_block  = var.vpc_cidr_block
  zone_count      = var.zone_count
  identifier      = "${var.prefix}-${terraform.workspace}"

  subnets = [
    for i in range(0, var.zone_count * var.subnet_count):
      cidrsubnet(var.vpc_cidr_block, 8, i)
  ]
}
