# --------------------------------------------------------------------------------
# EKS
# --------------------------------------------------------------------------------
# resource "aws_iam_policy_attachment" "ebs_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   roles      = [module.eks-cluster.worker-role]
#   name       = "AmazonEKS_EBS_CSI_DriverRole"
# }

resource "aws_iam_role_policy" "eks-role-policy" {
  role = module.eks-cluster.worker-role
  name = "${var.prefix}-eks"

  policy = templatefile("./policies/eks.json", {
    workspace = terraform.workspace
    account   = data.aws_caller_identity.current.id
    kms_key   = aws_kms_key.key.arn
  })
}

# --------------------------------------------------------------------------------
# ECR
# --------------------------------------------------------------------------------

resource "aws_ecr_repository_policy" "ecr-policy" {
  for_each   = toset(local.ecr_repositories)
  repository = each.key

  policy = templatefile("./policies/ecr.json", {
    account = data.aws_caller_identity.current.id
  })
}

# --------------------------------------------------------------------------------
# EC2
# --------------------------------------------------------------------------------

resource "aws_iam_role" "admin" {
  assume_role_policy = file("./policies/assume-role.json")
  name               = "${var.prefix}-development-role"
}

resource "aws_iam_role_policy" "admin" {
  role = aws_iam_role.admin.id

  policy = templatefile("./policies/ec2.json", {
    account = data.aws_caller_identity.current.id
    kms_key = aws_kms_key.key.arn
  })
}

resource "aws_iam_instance_profile" "admin" {
  role = aws_iam_role.admin.name
  name = "${var.prefix}-admin"
}
