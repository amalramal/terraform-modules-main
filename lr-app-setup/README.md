# LedgerRun Application

Everything you need to deploy a LedgerRun Application to an Environment

This module creates the following

* Elastic Container Registry Repository
* IAM roles for Github Actions
* IAM roles for EKS Service Accounts
* MongoDB Authentication via AWS IAM Roles

## Data Sources

This module uses the following as data sources:

* Current AWS Account
* EKS Cluster: `name: var.environment`

<!-- BEGIN_TF_DOCS -->
## Examples

### Simple

```hcl
module "realm_service" {
  source = "git::git@github.com:ledgerrun/terraform-modules.git?ref=lr-app-setup/vX.Y.Z"

  environment               = "lr-dev"
  github_repository         = "ledgerrun/CTP-backend" # The Github Repo to give OIDC permissions to
  app_name                  = "budget-service"
  create_mongodb_atlas_user = true
  mongodb_atlas_role_name   = "readWriteAnyDatabase"
  mongodb_atlas_project_id  = "69d6b30e154d7e656f5768cd" # ledgerrun-preprod
}
```

## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >1.0.0 |
| aws | >= 5.0 |
| mongodbatlas | 2.10.0 |

## Providers

| Name | Version |
| ---- | ------- |
| aws | >= 5.0 |
| mongodbatlas | 2.10.0 |



## Resources

| Name | Type |
| ---- | ---- |
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.svc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.github_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [mongodbatlas_database_user.svc](https://registry.terraform.io/providers/mongodb/mongodbatlas/2.10.0/docs/resources/database_user) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.ecr_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| app\_name | The name of your application. i.e. budget-service, gateway-service, etc | `string` | n/a | yes |
| environment | The name of the environment in which to deploy | `string` | n/a | yes |
| github\_repository | Grant OIDC Authorization for this repository. Example ledgerrun/CTP-Backend | `string` | n/a | yes |
| aws\_region | The AWS Region | `string` | `"us-east-1"` | no |
| create\_ecr\_repository | Should an ECR repository be created for this service? | `bool` | `true` | no |
| create\_mongodb\_atlas\_user | Should an Atlas IAM user be created for this service? | `bool` | `false` | no |
| ecr\_scan\_on\_push | Scan the container for vulnerabilities on push? | `bool` | `true` | no |
| ecr\_tag\_mutability | The mutability of the ECR images. | `string` | `"MUTABLE"` | no |
| eks\_sa\_namespaces\_allowed\_secrets | A list of additional k8s namespaces that k8s services accounts are allowed to pull secrets from. Defaults to $var.environment | `list(string)` | `[]` | no |
| mongodb\_atlas\_db\_name | The Atlas dbw here the IAM user role should be granted | `string` | `"admin"` | no |
| mongodb\_atlas\_project\_id | The Project ID where your IAM user should be created | `string` | `null` | no |
| mongodb\_atlas\_role\_name | The Atlas role the IAM user should be granted | `string` | `"readAnyDatabase"` | no |

<!-- END_TF_DOCS -->
