data archive_file this {
  type        = "zip"
  source_file = "${path.module}/lambda-code/index.js"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource aws_lambda_function this {
  function_name = local.naming["lambda"]
  description   = "todo"

  runtime = "nodejs10.x"
timeout = 300

  role = aws_iam_role.this.arn

  filename         = data.archive_file.this.output_path
  source_code_hash = filebase64sha256(data.archive_file.this.output_path)
  handler          = "index.handler"

  environment {
    variables = {
      temporary_rule_identifier = var.temporary_rule_identifier
    }
  }

  tags = var.tags
}

resource aws_cloudwatch_event_rule this {
  name        = local.naming["event_rule"]
  description = "TODO"

  schedule_expression = "rate(5 minutes)"
  tags                = var.tags
}

resource aws_cloudwatch_event_target lambda {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = aws_lambda_function.this.arn
}

resource aws_lambda_permission allow_cloudwatch {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

