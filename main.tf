/* ====================
Modules
==================== */

/*- ALB logger(Lambda) -*/

module "alb_logger" {
  source        = "./modules/alb_logger"
  prefix        = "${var.prefix}"
  region        = "${var.region}"
  alb_name      = "${var.alb_name}"
  slack_channel = "${var.slack_channel}"
}
