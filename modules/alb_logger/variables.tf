/* ====================
Argument variables
==================== */
output "alb_log_bucket_name" {
  value       = "${aws_s3_bucket.ext-alb-log.bucket}"
  description = "Bucket name of ALB logs"
}

output "alb_log_bucket_arn" {
  value       = "${aws_s3_bucket.ext-alb-log.arn}"
  description = "Bucket ARN of ALB logs"
}

output "alb_log_bucket_id" {
  value       = "${aws_s3_bucket.ext-alb-log.id}"
  description = "Bucket ID of ALB logs"
}

/* ====================
Argument variables
==================== */

variable "prefix" {
  type        = "string"
  description = "name prefix"
}

variable "region" {
  type        = "string"
  description = "region name"
}

variable "alb_name" {
  type        = "string"
  description = "alb name"
}

variable "slack_channel" {
  type        = "string"
  default     = ""
  description = "webhook endpoint for slack channel"
}
