module "eks-cluster" {
  source      = "./modules/eks_cluster"
  prv_subnets = local.subnet_ids["app"]
  pub_subnets = local.subnet_ids["pub"]
  kms_key     = aws_kms_key.key.arn
  vpc_id      = module.vpc.vpc_id

  kubernetes_version = var.kubernetes_version
  instance_types     = var.eks_instance_types
  remote_access      = formatlist("%s/32", module.admin-server.private_ips)
  identifier         = "${var.prefix}-${terraform.workspace}"
  disk_size          = var.eks_disk_size
  min_nodes          = var.eks_node_size
  max_nodes          = var.eks_node_size
}
