module "realm_service" {
  source = "git::git@github.com:ledgerrun/terraform-modules.git?ref=lr-app-setup/vX.Y.Z"

  environment               = "lr-dev"
  github_repository         = "ledgerrun/CTP-backend" # The Github Repo to give OIDC permissions to
  app_name                  = "budget-service"
  create_mongodb_atlas_user = true
  mongodb_atlas_role_name   = "readWriteAnyDatabase"
  mongodb_atlas_project_id  = "69d6b30e154d7e656f5768cd" # ledgerrun-preprod
}
