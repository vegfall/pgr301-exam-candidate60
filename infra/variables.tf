variable "notification_email" {
  description = "The email address to send alarm notifications to"
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS Queue"
  type        = string
}

variable "oldest_message_threshold" {
  description = "The threshold (in seconds) for the age of the oldest message before triggering the alarm"
  type        = number
  default     = 300
}

variable "alarm_period" {
  description = "The time period (in seconds) over which the metric is evaluated"
  type        = number
  default     = 60
}

variable "evaluation_periods" {
  description = "The number of periods over which the specified condition must be met"
  type        = number
  default     = 1
}
