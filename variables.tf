/* ====================
Local variables
==================== */

variable "prefix" {
  type        = "string"
  default     = "sample"
  description = "name prefix"
}

variable "region" {
  type        = "string"
  default     = "ap-northeast-1"
  description = "region name"
}

variable "alb_name" {
  type        = "string"
  default     = "sample_alb"
  description = "alb name"
}

variable "slack_channel" {
  type        = "string"
  default     = ""
  description = "webhook endpoint for slack channel"
}
