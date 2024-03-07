resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each   = toset(local.ecr_repositories)
  repository = each.key

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "delete untagged",
        action       = { type = "expire" }

        selection = {
          countNumber = 1,
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days"
        }
      }
    ]
  })
}

resource "aws_ecr_repository" "repositories" {
  for_each = toset(local.ecr_repositories)

  image_tag_mutability = "MUTABLE"
  name                 = each.key

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.key.arn
  }
}
