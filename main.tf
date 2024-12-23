resource "aws_s3_bucket" "static_bucket" {
  bucket = "vics3.sctp-sandbox.com"
  force_destroy = true
}

# resource "aws_s3_bucket_public_access_block" "enable_public_access" {
#   bucket = aws_s3_bucket.static_bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  #depends_on = [ aws_s3_bucket_public_access_block.enable_public_access ]
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default"
  # description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  aliases = ["vics3.sctp-sandbox.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "SG"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
#  resource "aws_s3_bucket_website_configuration" "website" {
#    bucket = aws_s3_bucket.static_bucket.id
 
#    index_document {
#      suffix = "index.html"
#    }
#  }

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.sctp_zone.zone_id  #Zone ID of hosted zone: sctp-sandbox.com
  name    = "vics3"                    # Bucket name prefix, before your domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name  #S3 website configuration attribute: website_domain
    zone_id                = aws_s3_bucket.static_bucket.hosted_zone_id                  # Hosted zone of the S3 bucket, Attribute: hosted_zone_id
    evaluate_target_health = true
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = aws_s3_bucket.static_bucket.id
  zone_id      = aws_s3_bucket.static_bucket.hosted_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.sctp-sandbox.com"
  ]

  wait_for_validation = true

  tags = {
    Name = "sctp-sandbox.com"
  }
}