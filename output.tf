output "bucket_name" {
  value = aws_s3_bucket.static_bucket.id
}

# output "website_domain" {
#   value = aws_s3_bucket_website_configuration.website.website_domain
# }

# output "website_endpoint" {
#   value = aws_s3_bucket_website_configuration.website.website_endpoint
# }

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}



output "account_id" {
  description = "The AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}