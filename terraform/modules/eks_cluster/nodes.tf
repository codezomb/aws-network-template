# --------------------------------------------------------------------------------
# EC2 IAM Role
# --------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "aws-ebs-csi-driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "container-registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "container-insights" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "x-ray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy" "worker" {
  role = aws_iam_role.worker-node.name
  policy = templatefile(
    "${path.module}/files/node-policy.json", {
      kms_key = var.kms_key
    }
  )
}

resource "aws_iam_role" "worker-node" {
  assume_role_policy = file(
    "${path.module}/files/role-policy.json"
  )
}

# --------------------------------------------------------------------------------
# EC2 Workers
# --------------------------------------------------------------------------------

resource "aws_launch_template" "worker-nodes" {
  ebs_optimized = true
  image_id      = data.aws_ami.ami.image_id
  name          = "${var.identifier}-worker-nodes"

  user_data = base64encode(templatefile(
    "${path.module}/files/user_data.sh", {
      additional_userdata = var.user_data
      cluster_auth_base64 = aws_eks_cluster.control-plane.certificate_authority[0].data
      cluster_name        = aws_eks_cluster.control-plane.name
      endpoint            = aws_eks_cluster.control-plane.endpoint
    }
  ))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Environment = "${terraform.workspace}"
      Name        = "${var.identifier}-workers"
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.disk_size
    }
  }

  monitoring {
    enabled = true
  }
}

resource "aws_eks_node_group" "worker-nodes" {
  node_group_name_prefix = "${var.identifier}-workers-"
  cluster_name           = aws_eks_cluster.control-plane.name
  node_role_arn          = aws_iam_role.worker-node.arn
  instance_types         = var.instance_types
  subnet_ids             = var.prv_subnets

  launch_template {
    version = aws_launch_template.worker-nodes.latest_version
    id      = aws_launch_template.worker-nodes.id
  }

  scaling_config {
    desired_size = var.min_nodes
    min_size     = var.min_nodes
    max_size     = var.max_nodes
  }

  depends_on = [
    aws_iam_role_policy_attachment.container-registry,
    aws_iam_role_policy_attachment.worker-node,
    aws_iam_role_policy_attachment.cni
  ]

  lifecycle {
    create_before_destroy = true
  }
}
