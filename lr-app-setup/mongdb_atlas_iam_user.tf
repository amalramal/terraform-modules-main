resource "mongodbatlas_database_user" "svc" {
  count = var.create_mongodb_atlas_user ? 1 : 0

  username           = aws_iam_role.svc.arn
  project_id         = var.mongodb_atlas_project_id
  auth_database_name = "$external"
  aws_iam_type       = "ROLE"

  roles {
    role_name     = var.mongodb_atlas_role_name
    database_name = var.mongodb_atlas_db_name
  }

  scopes {
    name = var.environment
    type = "CLUSTER"
  }
}
