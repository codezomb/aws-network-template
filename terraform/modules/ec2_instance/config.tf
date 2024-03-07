# ----------------------------------------------------------------------------------------------------------------------
# Variables
# ----------------------------------------------------------------------------------------------------------------------

variable "iam_instance_profile" { default = "" }
variable "source_dest_check"    { default = true }
variable "vpc_subnet_ids"       { type = list(string) }
variable "ebs_optimized"        { default = false }
variable "instance_type"        { default = "t2.medium" }
variable "volume_type"          { default = "gp3" }
variable "volume_size"          { default = 80 }
variable "identifier"           { /* Required */ }
variable "monitoring"           { /* Required */ }
variable "protected"            { default = false }
variable "user_data"            { default = "" }
variable "key_name"             { default = "" }
variable "vpc_id"               { /* Required */ }
variable "number"               { default = 1 }
variable "cost"                 { default = 0 }
variable "ami"                  { /* Required */ }

variable "group_ingress_rules" {
  type = list(any)
  default = []
}

variable "cidr_ingress_rules" {
  type = list(any)
  default = []
}

variable "egress_rules" {
  type = list(any)
  default = []
}

variable "tags" {
  default = {}
  type = map
}

# ----------------------------------------------------------------------------------------------------------------------
# Outputs
# ----------------------------------------------------------------------------------------------------------------------

output "zones" {
  value = aws_instance.ec2.*.availability_zone
}

output "security_group_id"  {
  value = aws_security_group.group.id
}

output "instance_ids" {
  value = aws_instance.ec2.*.id
}

output "private_ips" {
  value = aws_instance.ec2.*.private_ip
}

output "public_ips" {
  value = aws_instance.ec2.*.public_ip
}

output "ids" {
  value = aws_instance.ec2.*.id
}
