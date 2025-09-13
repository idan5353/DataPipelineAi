##############################
# Create HTTP API Gateway
##############################
resource "aws_apigatewayv2_api" "sentiment_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["http://localhost:3000"]  # your frontend URL
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    max_age       = 3600
  }
}

##############################
# Lambda permission for API Gateway
##############################
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.analyze.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.sentiment_api.execution_arn}/*/*"
}

##############################
# Create Lambda Integration
##############################
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.sentiment_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.analyze.arn
}

##############################
# Create Route for POST /upload
##############################
resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.sentiment_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

##############################
# Default Stage (auto deploys on changes)
##############################
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.sentiment_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "options_upload" {
  api_id    = aws_apigatewayv2_api.sentiment_api.id
  route_key = "OPTIONS /upload"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

##############################
# Optional: Output the full invoke URL
##############################
output "api_invoke_url" {
  value = "${aws_apigatewayv2_api.sentiment_api.api_endpoint}/$default/upload"
}
