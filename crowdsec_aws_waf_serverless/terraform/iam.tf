data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_policy_crowdsec" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:HeadObject",
    ]
    resources = ["${aws_s3_bucket.logging_bucket.arn}/*"]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.logging_bucket.arn]
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    ]
    resources = [aws_sqs_queue.log_notification.arn]
  }

  statement {
    actions = [
      "wafv2:DeleteIPSet",
      "wafv2:DeleteRuleGroup",
      "wafv2:CreateRuleGroup",
      "wafv2:UpdateWebACL",
      "wafv2:GetIPSet",
      "wafv2:UpdateRuleGroup",
      "wafv2:GetWebACL",
      "wafv2:GetRuleGroup",
      "wafv2:CreateIPSet",
      "wafv2:UpdateIPSet",
      "wafv2:TagResource"
    ]

    resources = [
      "arn:aws:wafv2:*:*:*/webacl/*/*",
      "arn:aws:wafv2:*:*:*/ipset/*/*",
      "arn:aws:wafv2:*:*:*/rulegroup/*/*"
    ]
  }

  statement {
    actions = [
      "wafv2:ListWebACLs",
      "wafv2:ListRuleGroups",
      "wafv2:ListIPSets"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ec2_policy_crowdsec" {
  name        = "crowdsec-ec2-policy"
  policy      = data.aws_iam_policy_document.ec2_policy_crowdsec.json
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name               = "crowdsec-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
