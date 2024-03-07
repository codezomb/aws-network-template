# ----------------------------------------------------------------------------------------------------------------------
# Private Routing
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "prv" {
  route_table_id = element(aws_route_table.prv.*.id, count.index % var.zone_count)
  subnet_id      = element(aws_subnet.prv.*.id, count.index)
  count          = length(local.prv_cidr_blocks)
}

resource "aws_route_table" "prv" {
  vpc_id = aws_vpc.vpc.id
  count  = length(local.prv_cidr_blocks) > 0 ? var.zone_count : 0

  route {
    nat_gateway_id = element(aws_nat_gateway.prv-nat.*.id, count.index)
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.identifier}-prv"
  }

  # Needs to be ignored because pritunl
  # modifies the route table
  lifecycle {
    ignore_changes = [route]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Public Routing
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_route_table_association" "pub" {
  route_table_id = aws_route_table.pub.id
  subnet_id      = element(aws_subnet.pub.*.id, count.index)
  count          = length(local.pub_cidr_blocks)
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.vpc.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.identifier}-pub"
  }

  # Needs to be ignored because pritunl
  # modifies the route table
  lifecycle {
    ignore_changes = [route]
  }
}
