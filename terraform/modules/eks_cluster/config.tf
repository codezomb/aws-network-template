variable "kubernetes_version" { type = string }
variable "instance_types"     { type = list(string) }
variable "remote_access"      { type = list(string) }
variable "prv_subnets"        { type = list(string) }
variable "pub_subnets"        { type = list(string) }
variable "identifier"         { type = string }
variable "min_nodes"          { type = number }
variable "max_nodes"          { type = number }
variable "disk_size"          { type = number }
variable "kms_key"            { type = string }
variable "vpc_id"             { type = string }

variable "user_data" {
  default = ""
  type    = string
}

locals {
  subnet_ids = concat(
    var.pub_subnets,
    var.prv_subnets
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# AMI Map
# ----------------------------------------------------------------------------------------------------------------------

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    values = ["amazon-eks-node-${var.kubernetes_version}*"]
    name   = "name"
  }
}

# --------------------------------------------------------------------------------
# Output
# --------------------------------------------------------------------------------

output "cluster_ca_cert" {
  value = aws_eks_cluster.control-plane.certificate_authority[0].data
}

output "control-role" {
  value = aws_iam_role.control-plane.id
}

output "worker-role" {
  value = aws_iam_role.worker-node.id
}

output "endpoint" {
  value = aws_eks_cluster.control-plane.endpoint
}

output "arn" {
  value = aws_eks_cluster.control-plane.arn
}

output "id" {
  value = aws_eks_cluster.control-plane.id
}
