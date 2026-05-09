
variable "environment" {
  description = "The name of the environment in which to deploy"
  type        = string

  validation {
    condition     = contains(["lr-dev", "dev", "qa", "uat", "eval", "ppd", "feature", "preview", "prod"], var.environment)
    error_message = "Must be one of 'dev', 'qa', 'uat', 'eval', 'ppd', 'feature', 'preview', 'prod'"
  }
}

variable "app_name" {
  description = "The name of your application. i.e. budget-service, gateway-service, etc"
  type        = string
}

variable "github_repository" {
  description = "Grant OIDC Authorization for this repository. Example ledgerrun/CTP-Backend"
  type        = string
}

#
# Optional
##################

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS Region"
  type        = string
}

variable "create_ecr_repository" {
  description = "Should an ECR repository be created for this service?"
  default     = true
  type        = bool
}

variable "create_mongodb_atlas_user" {
  description = "Should an Atlas IAM user be created for this service?"
  default     = false
  type        = bool
}

variable "ecr_tag_mutability" {
  description = "The mutability of the ECR images."
  default     = "MUTABLE"
  type        = string
}

variable "ecr_scan_on_push" {
  description = "Scan the container for vulnerabilities on push?"
  type        = bool
  default     = true
}

variable "eks_sa_namespaces_allowed_secrets" {
  description = "A list of additional k8s namespaces that k8s services accounts are allowed to pull secrets from. Defaults to $var.environment"
  default     = []
  type        = list(string)
}

variable "mongodb_atlas_project_id" {
  description = "The Project ID where your IAM user should be created"
  default     = null
  type        = string
}

variable "mongodb_atlas_role_name" {
  description = "The Atlas role the IAM user should be granted"
  default     = "readAnyDatabase"
  type        = string
}

variable "mongodb_atlas_db_name" {
  description = "The Atlas dbw here the IAM user role should be granted"
  default     = "admin"
  type        = string
}


locals {
  eks_namespaces_allowed_secrets = length(var.eks_sa_namespaces_allowed_secrets) > 0 ? var.eks_sa_namespaces_allowed_secrets : [var.environment]
}
