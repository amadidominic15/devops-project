resource "aws_iam_role" "gateway_api_controller" {
  name               = "${var.project}-${var.environment}-gateway-api"
  assume_role_policy = data.aws_iam_policy_document.gateway_api_assume_role.json
}

resource "aws_iam_policy" "gateway_api" {
  name = "${var.project}-${var.environment}-gateway-api-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ALB / ELB management
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },

      # EC2 networking (required for ALB)
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },

      # ACM (for HTTPS)
      {
        Effect = "Allow"
        Action = [
          "acm:DescribeCertificate"
        ]
        Resource = "*"
      },

      # IAM
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      },

      # Tagging
      {
        Effect = "Allow"
        Action = [
          "tag:GetResources",
          "tag:TagResources"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gateway_api" {
  role       = aws_iam_role.gateway_api_controller.name
  policy_arn = aws_iam_policy.gateway_api.arn
}



