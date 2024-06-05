data "aws_iam_policy_document" "sqs_policy" {
 statement {
    sid    = "publication"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.logging_bucket.arn]
    }
  }

  statement {
    sid    = "subscription"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ec2_role.arn]
    }

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = ["arn:aws:sqs:*"]
  }
}

resource "aws_sqs_queue" "log_notification" {
  name = "crowdsec-log-notification"
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.log_notification.id
  policy    = data.aws_iam_policy_document.sqs_policy.json
}

output "sqs_queue_name" {
	  value = aws_sqs_queue.log_notification.name
}