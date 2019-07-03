import os
import gzip
import re
import csv
import requests
import boto3
import logging
import json
import traceback
from io import StringIO
logger = logging.getLogger()
http_4xx5xx = re.compile('^(4|5)[0-9]{2}$')
s3 = boto3.client('s3')

SLACK_CHANNEL = "${slack_channel}"
LOG_BUCKET = "${log_bucket}"
ARCHIVE_BUCKET = "${archive_bucket}"
PREFIX = "${prefix}"

Keys = [
    'type',
    'timestamp',
    'elb',
    'client:port',
    'target:port',
    'request_processing_time',
    'target_processing_time',
    'response_processing_time',
    'elb_status_code',
    'target_status_code',
    'received_bytes',
    'sent_bytes',
    'request',
    'user_agent',
    'ssl_cipher',
    'ssl_protocol',
    'target_group_arn',
    'trace_id',
    'domain_name',
    'chosen_cert_arn',
    'matched_rule_priority',
    'request_creation_time',
    'actions_executed',
    'redirect_url',
    'error_reason'
    ]



class FormatterJSON(logging.Formatter):
    def format(self, record):
        record.message = record.getMessage()
        if self.usesTime():
            record.asctime = self.formatTime(record, self.datefmt)
        j = {
            'logLevel': record.levelname,
            'timestamp': '%(asctime)s.%(msecs)dZ' % dict(asctime=record.asctime, msecs=record.msecs),
            'timestamp_epoch': record.created,
            'aws_request_id': getattr(record, 'aws_request_id', '00000000-0000-0000-0000-000000000000'),
            'message': record.message,
            'module': record.module,
            'filename': record.filename,
            'funcName': record.funcName,
            'levelno': record.levelno,
            'lineno': record.lineno,
            'traceback': {},
            'extra_data': record.__dict__.get('extra_data', {}),
            'event': record.__dict__.get('event', {}),
        }
        if record.exc_info:
            exception_data = traceback.format_exc().splitlines()
            j['traceback'] = exception_data
 
        return json.dumps(j, ensure_ascii=False)
 
logger.setLevel('INFO')
formatter = FormatterJSON(
    '[%(levelname)s]\t%(asctime)s.%(msecs)dZ\t%(levelno)s\t%(message)s\n',
    '%Y-%m-%dT%H:%M:%S'
)
logger.handlers[0].setFormatter(formatter)

def post_slack(
  slack_url='',
  text='sample text',
  color='#AAAAAA',
  title='',
  attachment_text='sample attachment text'
  ):
  if len(slack_url) == 0:
    raise Exception('Slack URL(webhook endpoint) is undefined.')

  payload = {
    "text": text,
    "attachments": [
      {
        "color": color,
        "title": title,
        "text": attachment_text
      }
    ]
  }
  data = json.dumps(payload)
 
  try:
    response = requests.post(slack_url, data)
  except Exception as e:
    logger.error(f'request failure: GET {slack_url}')
    raise e
  else:
    logger.info(f'request result: {response.status_code}\n{response.text}')

def get_log_archives():
  log_archive_entries = s3.list_objects(Bucket=LOG_BUCKET, Prefix=PREFIX).get('Contents') or list()
  return sorted([l['Key'] for l in log_archive_entries])

def transfer_log(key, retries=0):
  if retries == 5:
    return False
  try:
    s3.copy_object(
      Bucket=ARCHIVE_BUCKET,
      Key=key,
      CopySource={'Bucket': LOG_BUCKET, 'Key': key})
    s3.delete_object(Bucket=LOG_BUCKET, Key=key)
  except Exception as e:
    logger.exception("Exception", extra={'extra_data':e})
    transfer_log(key, retries+1)
  finally:
    return True

def main(event, context):
  log_archives = get_log_archives()
  for log_archive in log_archives:
    log_object = s3.get_object(Bucket=LOG_BUCKET, Key=log_archive)
    log_body = gzip.decompress(log_object['Body'].read())
    logs = csv.reader(StringIO(log_body.decode()), delimiter=' ', doublequote=True)        
    for log in logs:
        item = dict()
        for i in range(0, len(Keys)):
            item[Keys[i]] = log[i]
        logger.info("", extra={'extra_data':item})
        if (http_4xx5xx.match(item['elb_status_code']) or http_4xx5xx.match(item['target_status_code'])) is not None and (len(SLACK_CHANNEL) != 0):
            post_slack(
                slack_url=SLACK_CHANNEL,
                text='',
                color='#FFAA00',
                title=f"{item['domain_name']}: [ ALB: {item['elb_status_code']}, APP: {item['target_status_code']}]",
                attachment_text=f"```ALB Trace Id: {item['trace_id']}\nUserAgent: {item['user_agent']}\n{item['timestamp']}```")
    transfer_log(log_archive)


if __name__ == "__main__":
  main()