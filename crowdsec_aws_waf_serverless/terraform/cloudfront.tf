resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "enable_acl" {
  bucket = aws_s3_bucket.logging_bucket.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket     = aws_s3_bucket.logging_bucket.bucket
  depends_on = [aws_s3_bucket_ownership_controls.enable_acl]
  access_control_policy {
    owner {
      id = data.aws_canonical_user_id.current.id
    }
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    grant {
      grantee {
        type = "CanonicalUser"
        id  = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
      }
      permission = "FULL_CONTROL"
    }
  }
}

resource "aws_s3_bucket_notification" "logfile_notification" {
  bucket = aws_s3_bucket.logging_bucket.bucket
  queue {
    queue_arn = aws_sqs_queue.log_notification.arn
    events    = ["s3:ObjectCreated:*"]
  }

}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled         = true
  is_ipv6_enabled = true
  origin {
    #domain_name = aws_api_gateway_deployment.deployment.invoke_url
    domain_name = "${aws_api_gateway_rest_api.api_gateway.id}.execute-api.${var.aws_region}.amazonaws.com"
    origin_path = "/demo"
    origin_id   = "api_gateway"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "api_gateway"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  logging_config {
    bucket          = aws_s3_bucket.logging_bucket.bucket_domain_name
    include_cookies = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = aws_wafv2_web_acl.webacl.arn
}

output "cf_domain" {
  value = aws_cloudfront_distribution.cf_distribution.domain_name
}
