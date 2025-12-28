

resource "aws_ecr_repository" "repos" {
  for_each = toset(var.components)

  name                 = "${var.project}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}