resource "aws_api_gateway_rest_api" "oidc" {
  name = "oidc-rest"
}

resource "aws_api_gateway_resource" "oidc" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  parent_id   = aws_api_gateway_rest_api.oidc.root_resource_id
  path_part   = "oidc"
}

resource "aws_api_gateway_resource" "wellknown" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  parent_id   = aws_api_gateway_resource.oidc.id
  path_part   = ".well-known"
}

resource "aws_api_gateway_resource" "jwks" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  parent_id   = aws_api_gateway_resource.wellknown.id
  path_part   = "jwks"
}

resource "aws_api_gateway_resource" "oidconfig" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  parent_id   = aws_api_gateway_resource.wellknown.id
  path_part   = "openid-configuration"
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  triggers = {
    jwks      = sha1(aws_api_gateway_integration_response.jwks.response_templates["application/json"])
    wellknown = sha1(aws_api_gateway_integration_response.oidconfig.response_templates["application/json"])
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage1" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = aws_api_gateway_rest_api.oidc.id
  stage_name    = "stage1"
}

resource "time_sleep" "complete_apigw" {
  depends_on      = [aws_api_gateway_stage.stage1]
  create_duration = "5s"
}

locals {
  stage_root = "https://${aws_api_gateway_rest_api.oidc.id}.execute-api.${data.aws_region.current.region}.amazonaws.com/stage1"
}
