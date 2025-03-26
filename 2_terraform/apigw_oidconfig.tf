resource "aws_api_gateway_method" "oidconfig" {
  rest_api_id   = aws_api_gateway_rest_api.oidc.id
  resource_id   = aws_api_gateway_resource.oidconfig.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "oidconfig" {
  rest_api_id          = aws_api_gateway_rest_api.oidc.id
  resource_id          = aws_api_gateway_resource.oidconfig.id
  http_method          = aws_api_gateway_method.oidconfig.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode({ "statusCode" : 200 })
  }
}

resource "aws_api_gateway_integration_response" "oidconfig" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  resource_id = aws_api_gateway_resource.oidconfig.id
  http_method = aws_api_gateway_integration.oidconfig.http_method
  status_code = 200

  response_templates = {
    "application/json" = jsonencode({
      issuer : "${local.stage_root}${aws_api_gateway_resource.oidc.path}"
      jwks_uri : "${local.stage_root}${aws_api_gateway_resource.jwks.path}"
      claims_supported : []
      response_types_supported : ["id_token"]
      subject_types_supported : ["public"]
      id_token_signing_alg_values_supported : ["RS256"]
    })
  }
}

resource "aws_api_gateway_method_response" "oidconfig" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  resource_id = aws_api_gateway_resource.oidconfig.id
  http_method = aws_api_gateway_method.oidconfig.http_method
  status_code = 200
}
