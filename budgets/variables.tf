variable "aws_region" {
  description = "AWS region for the provider (AWS Budgets is account-wide, not region-scoped, but the provider still needs one)"
  type        = string
  default     = "us-east-1"
}

variable "budget_name" {
  description = "Name of the AWS Budgets cost budget"
  type        = string
  default     = "harness-fde-lab-monthly-budget"
}

variable "monthly_limit_usd" {
  description = "Monthly account spend limit in USD that this budget tracks against. No default on purpose -- pick a real number for your account before applying."
  type        = number
}

variable "alert_emails" {
  description = "Email addresses to notify when a threshold below is crossed. No default on purpose -- set your own address(es) in terraform.tfvars."
  type        = list(string)
}

variable "notifications" {
  description = "Budget notification thresholds. Each entry emails alert_emails when spend crosses threshold_percent of monthly_limit_usd. type is \"ACTUAL\" (spend already happened) or \"FORECASTED\" (AWS's spend forecast for the period)."
  type = list(object({
    threshold_percent = number
    type              = string
  }))
  default = [
    { threshold_percent = 80, type = "ACTUAL" },
    { threshold_percent = 100, type = "FORECASTED" },
  ]
}
