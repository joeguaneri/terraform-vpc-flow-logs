data "aws_iam_policy_document" "flow_log_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name               = "FlowLogRole"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume_role.json
}

data "aws_iam_policy_document" "flow_log_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "flow_log_role_policy" {
  name   = "FlowLogRolePolicy"
  role   = aws_iam_role.vpc_flow_log_role.id
  policy = data.aws_iam_policy_document.flow_log_policy_document.json
}

resource "aws_s3_bucket" "flow_log_bucket" {
  bucket = var.bucket_name
}

resource "aws_flow_log" "flow_log" {
  log_destination      = aws_s3_bucket.flow_log_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  destination_options {
    file_format        = "parquet"
    per_hour_partition = true
  }
}