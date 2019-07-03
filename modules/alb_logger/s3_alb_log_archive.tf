/* ====================
Resources
==================== */

resource "aws_s3_bucket" "ext-alb-log-archive" {
  bucket = "${var.prefix}-external-lb-log-archive"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "ext-alb-log-archive" {
  bucket                  = "${aws_s3_bucket.ext-alb-log-archive.id}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
