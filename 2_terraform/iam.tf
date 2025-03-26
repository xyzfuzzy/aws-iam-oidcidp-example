resource "aws_iam_openid_connect_provider" "default" {
  url = "${local.stage_root}${aws_api_gateway_resource.oidc.path}"

  client_id_list = [
    "sts.amazonaws.com",
  ]
  depends_on = [time_sleep.complete_apigw]
}

resource "aws_iam_role" "test_role" {
  name = "oidc-sample-${aws_api_gateway_rest_api.oidc.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = aws_iam_openid_connect_provider.default.arn
        }
      },
    ]
  })
}

output "url_issuer" {
  value = "https://${aws_iam_openid_connect_provider.default.url}"
}

output "role_arn" {
  value = aws_iam_role.test_role.arn
}
