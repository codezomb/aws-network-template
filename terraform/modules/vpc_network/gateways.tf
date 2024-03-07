# ----------------------------------------------------------------------------------------
# NAT
# ----------------------------------------------------------------------------------------

resource "aws_nat_gateway" "prv-nat" {
  count         = length(local.prv_cidr_blocks) > 0 ? length(local.pub_cidr_blocks) : 0
  allocation_id = element(aws_eip.prv-nat.*.id, count.index)
  subnet_id     = element(aws_subnet.pub.*.id, count.index)
}

resource "aws_eip" "prv-nat" {
  count = length(local.prv_cidr_blocks) > 0 ? length(local.pub_cidr_blocks) : 0
  domain = "vpc"
}

# ----------------------------------------------------------------------------------------
# IGW
# ----------------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
