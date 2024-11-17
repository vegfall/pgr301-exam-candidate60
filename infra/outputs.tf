output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.image_request_queue.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarm notifications"
  value       = aws_sns_topic.notification_topic.arn
}

output "cloudwatch_alarm_name" {
  description = "Name of the CloudWatch alarm monitoring SQS"
  value       = aws_cloudwatch_metric_alarm.oldest_message_alarm.alarm_name
}
