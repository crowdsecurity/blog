resource "aws_wafv2_web_acl" "webacl" {

  provider = aws.us-east-1

  name  = "cloudfront-webacl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    sampled_requests_enabled   = false
    metric_name                = "wafacl_metric"
  }

  lifecycle {
    ignore_changes = [rule] //Ignore changes to rules as the RC will manage them
  }
}

output "web_acl_name" {
	  value = aws_wafv2_web_acl.webacl.name
}