resource "aws_s3_bucket" "static_bucket" {
  bucket = "jazeelstaticbucket.sctp-sandbox.com"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "enable_public_access" {
  bucket = aws_s3_bucket.static_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [ aws_s3_bucket_public_access_block.enable_public_access ]
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "null_resource" "s3_sync" {
  for_each = fileset("${var.static_files_directory}", "**/*")
  triggers = {
    file_changed = filemd5("${var.static_files_directory}/${each.key}")
  }
  provisioner "local-exec" {
    command = "aws s3 sync . s3://${aws_s3_bucket.static_bucket.id}"
    working_dir = "${var.static_files_directory}"
  }
}