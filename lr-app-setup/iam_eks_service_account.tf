locals {
  current_cluster_odic_id = trimprefix(data.aws_eks_cluster.current.identity[0].oidc[0].issuer, "https://")
  current_aws_account     = data.aws_caller_identity.current.id
}

data "aws_iam_policy_document" "trust" {
  dynamic "statement" {
    for_each = toset(local.eks_namespaces_allowed_secrets)
    content {

      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = ["arn:aws:iam::${local.current_aws_account}:oidc-provider/${local.current_cluster_odic_id}"]
      }

      condition {
        test     = "StringEquals"
        variable = "${local.current_cluster_odic_id}:aud"
        values   = ["sts.amazonaws.com"]
      }

      condition {
        # Use StringLike to allow for wildcards
        test     = "StringLike"
        variable = "${local.current_cluster_odic_id}:sub"
        values   = ["system:serviceaccount:${statement.value}:${var.app_name}"]
      }

    }
  }
}

resource "aws_iam_role" "svc" {
  name               = "eks-sa-${var.environment}-${var.app_name}"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy" "secret" {
  name = "${var.app_name}-${var.environment}-secrets-access"
  role = aws_iam_role.svc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
        ]
        Resource = [
          "arn:aws:secretsmanager:us-east-1:${local.current_aws_account}:secret:/secret/application_${var.environment}*"
        ]
      }
    ]
  })
}
