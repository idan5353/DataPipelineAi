###########################
# IAM Role for Lambda
###########################
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

###########################
# Attach Managed Policies to Lambda Role
###########################
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

###########################
# Custom S3 Policy for Lambda (Put/Get/List)
###########################
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "${var.project_name}-s3-policy"
  description = "Allow Lambda to get, put, and list objects in uploads bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.uploads.arn,          # ListBucket permission
          "${aws_s3_bucket.uploads.arn}/*"   # Put/Get permissions
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_s3_attach" {
  name       = "${var.project_name}-lambda-s3-attach"
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  roles      = [aws_iam_role.lambda_exec.name]
  depends_on = [
    aws_iam_policy.lambda_s3_policy,
    aws_iam_role.lambda_exec
  ]
}

###########################
# Lambda Function
###########################
resource "aws_lambda_function" "analyze" {
  function_name = "${var.project_name}-lambda"
  handler       = "handler.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn

  filename         = "${path.module}/lambda_src/package.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_src/package.zip")

  environment {
    variables = {
      UPLOAD_BUCKET = aws_s3_bucket.uploads.bucket
      TABLE_NAME    = aws_dynamodb_table.results.name
    }
  }
}

###########################
# Lambda Permission for S3 (Optional)
###########################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.analyze.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}
