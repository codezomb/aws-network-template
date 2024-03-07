# --------------------------------------------------------------------------------
# IAM Role
# --------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "cluster-vpc" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.control-plane.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.control-plane.name
}

resource "aws_iam_role" "control-plane" {
  assume_role_policy = file(
    "${path.module}/files/role-policy.json"
  )

  lifecycle {
    ignore_changes = [
      assume_role_policy
    ]
  }
}

# --------------------------------------------------------------------------------
# Security Group
# --------------------------------------------------------------------------------

resource "aws_security_group" "control-plane" {
  description = "${var.identifier}-control-plane"
  name        = "${var.identifier}-control-plane"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks = var.remote_access
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
  }

  ingress {
    protocol  = "TCP"
    from_port = 443
    to_port   = 443
    self      = true
  }

  tags = {
    Environment = "${terraform.workspace}"
    Name        = "${var.identifier}-control-plane"
  }
}

# --------------------------------------------------------------------------------
# Control Plane
# --------------------------------------------------------------------------------

resource "aws_eks_cluster" "control-plane" {
  role_arn = aws_iam_role.control-plane.arn
  version  = var.kubernetes_version
  name     = var.identifier

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = false
    subnet_ids = local.subnet_ids

    security_group_ids = [
      aws_security_group.control-plane.id
    ]
  }

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = var.kms_key
    }
  }

  enabled_cluster_log_types = [
    "authenticator",
    "audit",
    "api"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.cluster-vpc,
    aws_iam_role_policy_attachment.eks-cluster
  ]
}

# --------------------------------------------------------------------------------
# Addons
# --------------------------------------------------------------------------------

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.control-plane.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.control-plane.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "efs" {
  cluster_name = aws_eks_cluster.control-plane.name
  addon_name   = "aws-efs-csi-driver"
}

resource "aws_eks_addon" "ebs" {
  cluster_name = aws_eks_cluster.control-plane.name
  addon_name   = "aws-ebs-csi-driver"
}

resource "aws_eks_addon" "vpc" {
  cluster_name = aws_eks_cluster.control-plane.name
  addon_name   = "vpc-cni"
}

