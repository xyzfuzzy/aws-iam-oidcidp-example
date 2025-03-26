resource "aws_api_gateway_method" "jwks" {
  rest_api_id   = aws_api_gateway_rest_api.oidc.id
  resource_id   = aws_api_gateway_resource.jwks.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "jwks" {
  rest_api_id          = aws_api_gateway_rest_api.oidc.id
  resource_id          = aws_api_gateway_resource.jwks.id
  http_method          = aws_api_gateway_method.jwks.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = jsonencode({ "statusCode" : 200 })
  }
}

resource "aws_api_gateway_integration_response" "jwks" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  resource_id = aws_api_gateway_resource.jwks.id
  http_method = aws_api_gateway_integration.jwks.http_method
  status_code = 200

  response_templates = {
    "application/json" = jsonencode({ keys : [{
      kty : "RSA"
      kid : "k1"
      n : file("../tmp/public_modulus_base64")
      e : "AQAB"
    }] })
  }
}

resource "aws_api_gateway_method_response" "jwks" {
  rest_api_id = aws_api_gateway_rest_api.oidc.id
  resource_id = aws_api_gateway_resource.jwks.id
  http_method = aws_api_gateway_method.jwks.http_method
  status_code = 200
}
