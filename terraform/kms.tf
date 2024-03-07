resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.key.key_id
  name          = "alias/${var.prefix}"
}

resource "aws_kms_key" "key" {
  multi_region = true
}
