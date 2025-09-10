resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_comprehend" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/ComprehendFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "analyze" {
  function_name = "${var.project_name}-lambda"
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn

  filename         = "${path.module}/lambda_src/package.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_src/package.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.results.name
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.analyze.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "${var.project_name}-s3-policy"
  description = "Allow Lambda to get objects from the uploads bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "arn:aws:s3:::${aws_s3_bucket.uploads.bucket}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_s3_attach" {
  name       = "${var.project_name}-lambda-s3-attach"
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  roles      = [aws_iam_role.lambda_exec.name]
}

