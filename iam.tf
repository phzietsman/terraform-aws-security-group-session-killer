resource aws_iam_role this {
  name               = "${var.naming_prefix}-${local.naming["role"]}"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource aws_iam_policy this {
  name        = "${var.naming_prefix}-${local.naming["policy"]}"
  description = "Used by Security Group Session Killer lambda"

  policy = data.aws_iam_policy_document.permissions.json
}

resource aws_iam_role_policy_attachment this {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

// Build the policies

data aws_iam_policy_document trust {
  statement {
    sid = "TrustPolicy"

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]

  }
}

data aws_iam_policy_document permissions {
  statement {
    sid = "ListAndKillSGRules"

    effect = "Allow"

    actions = [
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DescribeSecurityGroups"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "LambdaLogging"

    effect = "Allow"

    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

