data "aws_caller_identity" "current" {}

# ----------------------------------------------------------------------------------------------------------------------
# Configuration Variables
# ----------------------------------------------------------------------------------------------------------------------

variable "vpc_cidr_block" { type = string }
variable "identifier"     { type = string }
variable "subnets"        { type = list(any) }

variable "subnet_count" {
  type = number
  default = 4
}

variable "zone_count" {
  type = number
  default = 3
}

variable "tags" {
  default = {}
  type = map
}

locals {
  prv_cidr_blocks = slice(var.subnets, var.zone_count, length(var.subnets))
  pub_cidr_blocks = slice(var.subnets, 0, var.zone_count)
}

# ----------------------------------------------------------------------------------------------------------------------
# Output
# ----------------------------------------------------------------------------------------------------------------------

output "public_nat_addresses" {
  value = aws_eip.prv-nat.*.public_ip
}

output "prv_route_table_ids" {
  value = aws_route_table.prv.*.id
}

output "pub_route_table_id" {
  value = aws_route_table.pub.id
}

output "prv_cidr_blocks" {
  value = local.prv_cidr_blocks
}

output "pub_cidr_blocks" {
  value = local.pub_cidr_blocks
}

output "prv_subnet_ids" {
  value = aws_subnet.prv.*.id
}

output "pub_subnet_ids" {
  value = aws_subnet.pub.*.id
}

output "cidr_block" {
  value = var.vpc_cidr_block
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
