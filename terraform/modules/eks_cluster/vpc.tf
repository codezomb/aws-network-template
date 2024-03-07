resource "aws_ec2_tag" "ownership" {
  count       = length(local.subnet_ids)
  resource_id = local.subnet_ids[count.index]
  key         = "kubernetes.io/cluster/${var.identifier}"
  value       = "owned"
}

resource "aws_ec2_tag" "internal-elb" {
  count       = length(var.prv_subnets)
  resource_id = var.prv_subnets[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "external-elb" {
  count       = length(var.pub_subnets)
  resource_id = var.pub_subnets[count.index]
  key         = "kubernetes.io/role/elb"
  value       = "1"
}
