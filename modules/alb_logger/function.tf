/* ====================
Resources
==================== */
data "aws_caller_identity" "current" {}

resource "template_dir" "alb_logger" {
  source_dir      = "${path.module}/src/function"
  destination_dir = "${path.module}/dest/function"

  vars {
    slack_channel  = "${var.slack_channel}"
    log_bucket     = "${aws_s3_bucket.ext-alb-log.bucket}"
    archive_bucket = "${aws_s3_bucket.ext-alb-log-archive.bucket}"
    prefix         = "${var.alb_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/elasticloadbalancing/${var.region}"
  }

  provisioner "local-exec" {
    command = "pip3 install --target=${template_dir.alb_logger.destination_dir} -r ${template_dir.alb_logger.destination_dir}/requirements.txt"
  }
}

data "archive_file" "zip_lambda_alb_logger" {
  depends_on  = ["template_dir.alb_logger"]
  type        = "zip"
  source_dir  = "${template_dir.alb_logger.destination_dir}"
  output_path = "${template_dir.alb_logger.destination_dir}.zip"
}

resource "aws_lambda_function" "alb_logger" {
  depends_on                     = ["data.archive_file.zip_lambda_alb_logger"]
  runtime                        = "python3.6"
  filename                       = "${data.archive_file.zip_lambda_alb_logger.output_path}"
  source_code_hash               = "${data.archive_file.zip_lambda_alb_logger.output_base64sha256}"
  function_name                  = "${var.prefix}-alb_logger"
  handler                        = "alb_logger.main"
  timeout                        = "300"
  memory_size                    = "128"
  reserved_concurrent_executions = "1"
  role                           = "${aws_iam_role.lambda.arn}"
}

resource "null_resource" "alb_logger" {
  depends_on = ["aws_lambda_function.alb_logger"]

  triggers {
    uuid = "${uuid()}"
  }

  provisioner "local-exec" {
    command = "rm ${data.archive_file.zip_lambda_alb_logger.output_path}"
  }
}
