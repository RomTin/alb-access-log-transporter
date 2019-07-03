/* ====================
Resources
==================== */

resource "aws_s3_bucket" "ext-alb-log" {
  bucket = "${var.prefix}-external-lb-log"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "ext-alb-log" {
  bucket                  = "${aws_s3_bucket.ext-alb-log.id}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.alb_logger.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.ext-alb-log.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.ext-alb-log.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.alb_logger.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
