resource "aws_cloudwatch_metric_alarm" "oldest_message_alarm" {
  alarm_name          = "sqs_oldest_message_age_alarm_60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = var.alarm_period
  statistic           = "Maximum"
  threshold           = var.oldest_message_threshold
  alarm_description   = "This alarm monitors the age of the oldest message in the SQS queue and triggers when it exceeds the threshold."
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.notification_topic.arn]
  dimensions = {
    QueueName = var.sqs_queue_name
  }
}

resource "aws_sns_topic" "notification_topic" {
  name = "sqs-alarm-notification-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
