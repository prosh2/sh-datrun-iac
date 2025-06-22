resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:prosh2/sh-datrun-dp:*",
        # data-robot
        "repo:haojunsng/data_robot:*"
      ]
    }
  }
}

data "aws_iam_policy_document" "github_actions" {

  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.sh_datrun_lambda_bucket.arn,
      "${aws_s3_bucket.sh_datrun_lambda_bucket.arn}/*",
      # data-robot
      "arn:aws:s3:::data-robot-franky",
      "arn:aws:s3:::data-robot-franky/*"
    ]
  }
}

resource "aws_iam_role" "sh_datrun_dp_gha" {
  name               = "sh-datrun-dp-gha"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_policy" "sh_datrun_dp_gha_policy" {
  name   = "sh-datrun-dp-gha-policy"
  policy = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.sh_datrun_dp_gha.name
  policy_arn = aws_iam_policy.sh_datrun_dp_gha_policy.arn
}
