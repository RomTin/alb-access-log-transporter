/* ====================
Local variables
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
