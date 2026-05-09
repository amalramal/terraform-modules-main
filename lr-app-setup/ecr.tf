resource "aws_ecr_repository" "repo" {
  count                = var.create_ecr_repository ? 1 : 0
  name                 = "${var.environment}/${var.app_name}"
  image_tag_mutability = var.ecr_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }
}
