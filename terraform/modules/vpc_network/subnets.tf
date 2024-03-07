data "aws_availability_zones" "available" {}

resource "aws_subnet" "pub" {
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index % var.zone_count)
  cidr_block              = element(local.pub_cidr_blocks, count.index)
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.pub_cidr_blocks)

  tags = merge(
    tomap({
      "Name" = "${var.identifier}-pub"
    }),
    var.tags
  )

  # Needs to be ignored because
  # k8s modifies the tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "prv" {
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index % var.zone_count)
  cidr_block              = element(local.prv_cidr_blocks, count.index)
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(local.prv_cidr_blocks)

  tags = merge(
    tomap({
      "Name" = "${var.identifier}-prv"
    }),
    var.tags
  )

  # Needs to be ignored because
  # k8s modifies the tags
  lifecycle {
    ignore_changes = [tags]
  }
}
