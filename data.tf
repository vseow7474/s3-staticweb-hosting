data "aws_route53_zone" "sctp_zone" {
  name = "sctp-sandbox.com"
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
      ]
    }
    resources = [
      "${aws_s3_bucket.static_bucket.arn}/*",
    ]
  }
}

data "aws_caller_identity" "current" {}