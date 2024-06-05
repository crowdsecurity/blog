resource "aws_api_gateway_rest_api" "api_gateway" {
	name = "crowdsec-api-gateway"
	description = "CrowdSec API Gateway"
	endpoint_configuration {
		types = ["REGIONAL"]
	}
}

resource "aws_api_gateway_method" "method" {
	rest_api_id = aws_api_gateway_rest_api.api_gateway.id
	resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
	http_method = "GET"
	authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
	rest_api_id = aws_api_gateway_rest_api.api_gateway.id
	resource_id = aws_api_gateway_rest_api.api_gateway.root_resource_id
	http_method = aws_api_gateway_method.method.http_method
	integration_http_method = "POST"
	type = "AWS_PROXY"
	uri = aws_lambda_function.hello_world.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "demo"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}

output "api_gateway_url" {
	value = aws_api_gateway_deployment.deployment.invoke_url
}